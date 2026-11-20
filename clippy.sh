#!/usr/bin/env bash
# clippy — copy every text file in a folder (recursively, .gitignore-aware)
# to the clipboard as one neatly styled Markdown document.
#
# Usage:
#   clippy            # current folder
#   clippy path/to/dir
#
# Needs: xclip (preferred) or xsel, and git for .gitignore handling.
#   sudo apt install xclip

set -euo pipefail

target="${1:-.}"
if [[ ! -d "$target" ]]; then
    echo "clippy: '$target' is not a directory" >&2
    exit 1
fi
target="$(cd "$target" && pwd)"

# ---- pick a clipboard tool -------------------------------------------------
if command -v xclip >/dev/null 2>&1; then
    copy_cmd=(xclip -selection clipboard)
elif command -v xsel >/dev/null 2>&1; then
    copy_cmd=(xsel --clipboard --input)
else
    echo "clippy: install xclip first (sudo apt install xclip)" >&2
    exit 1
fi

# ---- collect files ---------------------------------------------------------
# Inside a git repo: tracked + untracked-but-not-ignored, honouring every
# .gitignore. Outside one: plain find, pruning the usual junk directories.
list_files() {
    if git -C "$target" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -C "$target" ls-files -z --cached --others --exclude-standard
    else
        ( cd "$target" && find . -type f \
            -not -path './.git/*' -print0 | sed -z 's|^\./||' )
    fi
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

count=0
toc=""
body=""

while IFS= read -r -d '' rel; do
    path="$target/$rel"
    [[ -f "$path" ]] || continue
    # Skip anything that is not plain text (binaries, images, archives).
    if ! grep -Iq . "$path" 2>/dev/null && [[ -s "$path" ]]; then
        continue
    fi
    # Skip the .git directory itself, if it ever slips through.
    [[ "$rel" == .git/* || "$rel" == */.git/* ]] && continue

    lang="${rel##*.}"
    [[ "$lang" == "$rel" ]] && lang=""   # no extension -> no highlighting hint
    anchor="$(printf '%s' "$rel" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')"

    toc+="- [\`${rel}\`](#${anchor})"$'\n'
    body+="---"$'\n\n'
    body+="## <a id=\"${anchor}\"></a>\`${rel}\`"$'\n\n'
    body+="\`\`\`${lang}"$'\n'
    body+="$(cat "$path")"$'\n'
    body+="\`\`\`"$'\n\n'
    count=$((count + 1))
done < <(list_files)

if (( count == 0 )); then
    echo "clippy: no text files found in '$target'" >&2
    exit 1
fi

# ---- assemble the document -------------------------------------------------
{
    printf '# %s\n\n' "$(basename "$target")"
    printf '> **%d** file(s) · copied %s · from `%s`\n\n' \
        "$count" "$(date '+%Y-%m-%d %H:%M')" "$target"
    printf '## Contents\n\n%s\n' "$toc"
    printf '%s' "$body"
} > "$tmp"

"${copy_cmd[@]}" < "$tmp"

echo "clippy: copied $count file(s) from '$target' to the clipboard."
