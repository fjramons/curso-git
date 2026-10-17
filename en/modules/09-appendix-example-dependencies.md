# Appendix: example dependencies

The tools in this appendix **are not needed to use Git or GitHub**. They are only used in the example that runs through the course: the `build.sh` script from section 2.5 converts the Git Handbook, written in Markdown, to Word, PDF and HTML. If you are only interested in Git, you can skip this appendix and read the sections of the book without generating it.

On GitHub there is nothing to install: in module 8, the CI installs these same tools on its own machines to publish each version of the book.

## What is installed and why

- **Pandoc**: a universal document converter. It reads the chapters in Markdown and generates the `.docx` and the `.html`. It is essential for the example.
- **Typst** (optional): a typesetting engine that Pandoc uses to generate the PDF. It was chosen instead of LaTeX, the classic option, because it is a single small program that is easy to install, whereas a LaTeX installation takes up several GB. If you don't install Typst, `build.sh` shows a warning and still generates the Word file and the HTML.

## Installation

On **Linux** (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install pandoc
```

The version of Pandoc in your distribution's repositories may be old. If `build.sh` gives errors, install the latest one from the [Pandoc download page](https://pandoc.org/installing.html).

Typst isn't in the Debian or Ubuntu repositories. The simplest way to install it is to download the official program from its [releases page](https://github.com/typst/typst/releases): it is a single file that needs neither a package manager nor administrator permissions. These commands download the latest version, unpack it and copy it to `~/.local/bin`, the usual folder for your user's programs:

```bash
curl -LO https://github.com/typst/typst/releases/latest/download/typst-x86_64-unknown-linux-musl.tar.xz
tar -xf typst-x86_64-unknown-linux-musl.tar.xz
mkdir -p ~/.local/bin
mv typst-x86_64-unknown-linux-musl/typst ~/.local/bin/
```

If your computer has an ARM processor (for example, a Raspberry Pi), replace `x86_64` with `aarch64` in the first two lines. If `typst --version` then says it can't find the program, `~/.local/bin` isn't in your `PATH`. On Ubuntu it is added automatically when you log in if the folder exists, so it is enough to log out and back in. On other distributions, add `export PATH="$HOME/.local/bin:$PATH"` at the end of your `~/.bashrc`.

Other ways to install Typst on Linux:

- With [Homebrew on Linux](https://docs.brew.sh/Homebrew-on-Linux), if you already use it: `brew install typst`.
- With the package manager of distributions that include it, such as Arch Linux: `sudo pacman -S typst`.
- With snap: `sudo snap install typst`.
- By building it with the Rust tools: `cargo install --locked typst-cli`.

On **macOS**, with [Homebrew](https://brew.sh):

```bash
brew install pandoc typst
```

On **Windows**, from PowerShell:

```powershell
winget install --id JohnMacFarlane.Pandoc -e
winget install --id Typst.Typst -e
```

## Checking the installation

Close and reopen the terminal (Git Bash on Windows) and check that both tools respond:

```bash
pandoc --version
typst --version
```

Each command shows the installed version. If `typst --version` fails and you don't want the PDF, you can carry on without any problem.

To open the generated book you will also need a program that reads `.docx` files, such as Microsoft Word or LibreOffice, and a PDF viewer. `index.html` opens in any browser.
