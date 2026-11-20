# clippy

Copy an entire project to your clipboard as one clean Markdown document.

`clippy` walks a folder, skips anything your `.gitignore` excludes, and puts every text file on the clipboard, each under its own heading with syntax-highlighted code. Paste it into an AI chat, a bug report, a gist, or a doc in one go.

It's a single bash script. No Python, no build step.

## Features

- **Recursive.** Takes every text file in the folder and its subfolders.
- **Respects `.gitignore`.** Uses `git ls-files`, so nested `.gitignore` files and `.git/info/exclude` all apply.
- **Skips binaries.** Images, archives and other non-text files are left out.
- **Styled output.** A title, a file count, a clickable table of contents, and a fenced code block per file, tagged by extension.
- **Clear failures.** Says so when there are no text files or no clipboard tool is installed.

## Requirements

- Linux with an X11 desktop (tested on Linux Mint with XFCE)
- `xclip` (preferred) or `xsel`
- `git` (optional, but needed for `.gitignore` handling inside repos)

Install the clipboard tool:

```bash
sudo apt install xclip
```

## Installation

```bash
git clone https://github.com/0xProgress/clippy.git
cd clippy
mkdir -p ~/.local/bin
cp clippy ~/.local/bin/clippy
chmod +x ~/.local/bin/clippy
```

Make sure `~/.local/bin` is on your `PATH`. Most distros, Mint included, add it automatically when the folder exists at login. If not, add this line to `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

```bash
cd ~/some-project
clippy              # the current folder
clippy ~/other      # or any folder
```

When it finishes you'll see:

```
clippy: copied 12 file(s) from '/home/you/some-project' to the clipboard.
```

Then paste with `Ctrl+V` wherever you need it.

## Output format

````markdown
# some-project

> **12** file(s) · copied 2026-11-20 15:49 · from `/home/you/some-project`

## Contents

- [`README.md`](#readme-md)
- [`src/main.py`](#src-main-py)

---

## <a id="readme-md"></a>`README.md`

```md
...file contents...
```
````

## Limitations

- Very large folders produce a very large clipboard entry. Some apps truncate pastes past a few MB.
- A file containing triple backticks can break the Markdown fence. This is uncommon in source code.
- X11 only. Wayland clipboard support would need `wl-copy` added.

## License under MIT

See [LICENSE](./LICENSE) for details.
