# Module 2: Local version control (Git basics)

In this module, the `git-handbook` folder will become a Git repository and our book will get its first chapters. Along the way we will see the basic work cycle (modify, stage and commit), how to undo changes before saving them, how to read the history and, finally, how to generate the book in Word with Pandoc.

## 2.1 Initializing a repository

A **repository** is a folder whose history is controlled by Git. Our starting point is the empty folder we created in the previous module, so we begin by moving into it:

```bash
cd ~/projects/git-handbook
```

Every book needs an introduction, so create an empty `README.md` file, which we will fill in shortly. Next, we ask Git to start tracking the folder:

```bash
touch README.md
git init
```

`git init` creates a hidden `.git` folder, where Git will store the whole history. You can see it with `ls -a`, but don't touch it by hand: if you delete it, you lose the project's entire history.

For historical reasons, Git may call the main branch `master`. Today the usual name (and the one GitHub uses) is `main`, so it is a good idea to rename it:

```bash
git branch -M main
```

If you want all your new repositories to start with `main` directly, just run `git config --global init.defaultBranch main` once. With the repository created, we can ask Git how it is doing:

```bash
git status
```

`git status` will be, by far, the command you use most. Its output says that the current branch is `main`, that there are no commits yet and that `README.md` is an _untracked_ file: Git sees it, but doesn't control it yet.

## 2.2 File lifecycle: the staging area and commits

In Git, a change goes through three areas before it is saved:

1. **Working directory**: the files as you see and edit them.
2. **Staging area** (or _index_): an intermediate area where you prepare what will be saved in the next commit.
3. **Repository**: the history of commits, stored in `.git`.

`git add` moves changes from the working directory to the staging area, and `git commit` saves everything in the staging area to the repository. This separation lets you decide which changes go together in each commit, even if many files have been modified at once.

```{.dot caption="The three areas of Git" alt="The working directory moves to the staging area with git add, and the staging area moves to the repository with git commit"}
digraph {
  rankdir=LR
  node [shape=box]
  trabajo [class=zona label="Working directory"]
  staging [class=zona label="Staging"]
  repo [class=zona label="Repository (.git)"]
  trabajo -> staging [class=accion label="  git add  "]
  staging -> repo [class=accion label="  git commit  "]
}
```

Before writing, it is worth knowing what format we will write in. Our book is written in **Markdown**, a plain text format in which a few symbols indicate the formatting: `#` for headings, `**` for bold, `-` for lists… Its syntax is explained in detail in section 6.3, but there is no need to wait or to memorize it: the _Markdown Guide_ (<https://www.markdownguide.org>) explains it step by step and its cheat sheet (<https://www.markdownguide.org/cheat-sheet>) sums it up on one page. Look it up whenever you are unsure how to format something.

Let's put the three areas into practice with the README. Open it with your editor (for example, `code README.md` if you use VS Code) and write an introduction to the book:

```markdown
# Git Handbook

A book written in Markdown during the Git and GitHub course.
```

Save the file and then add it to the staging area and check the status:

```bash
git add README.md
git status
```

Now `README.md` appears in green, under _Changes to be committed_, which means it is staged. All that is left is to save it to the history with a commit, whose message should briefly explain what changes:

```bash
git commit -m "Add the book README"
```

The repository now has its first commit, so the natural next step is to write the first chapter. The chapters will live in a `chapters` folder, numbered so that they sort themselves:

```bash
mkdir chapters
code chapters/01-what-is-git.md
```

Write this content (or your own version, with what you learned in module 1):

```markdown
# What is Git?

Git is a distributed version control system. It keeps the full history of a project and lets you go back to any earlier version.

GitHub is a web platform that hosts Git repositories and makes it easier for people to collaborate.
```

To save it we will use `git add -A` this time, which adds every change in the repository to the staging area (new, modified and deleted files), whatever folder you are in. It is very convenient, but it is worth checking first with `git status` that nothing you don't want is slipping in:

```bash
git add -A
git commit -m "Add chapter 1: what is Git"
```

In many tutorials you will see `git add .`, which does the same but only with the current folder and its subfolders. From the root of the repository the result is identical; inside a subfolder, on the other hand, it leaves out the changes in the rest of the project. Use it only when you deliberately want to limit what you stage: for example, `cd chapters` followed by `git add .` to include only the chapters in the commit. In this course we will always use `git add -A`.

With two commits we already have a small history, which you can view with `git log`:

```bash
git log
```

Each commit shows a unique identifier (a 40-character _hash_ such as `a1b2c3d…`), the author, the date and the message, and the most recent one appears at the top. If the list is long, move around with the arrow keys and press `q` to quit.

## 2.3 Discarding changes before saving (checkout and reset)

Making mistakes is part of the job, so it is worth knowing how to back out. To practice we need a mistake, and the simplest thing is to make one: we are going to deliberately break chapter 1 with a command that overwrites the whole file with a single line:

```bash
echo "Text I wrote by accident" > chapters/01-what-is-git.md
git status
```

`git status` shows the file as _modified_ in red: the change is in the working directory, but not in the staging area. Suppose we want to forget it and get back the version from the last commit. All it takes is:

```bash
git checkout chapters/01-what-is-git.md
```

If you open the file, you will see that it has its original content again. Be careful, though, because changes discarded this way cannot be recovered.

Now let's make the scenario a little more complicated: we repeat the mistake, but this time we go as far as adding it to the staging area, as if we had accepted it:

```bash
echo "Text I wrote by accident" > chapters/01-what-is-git.md
git add chapters/01-what-is-git.md
```

The change is now staged for the next commit, and what we want is to take it out of the staging area without losing it yet. For that we use `git reset HEAD`, where `HEAD` is the name Git gives to the commit the repository is on at that moment:

```bash
git reset HEAD chapters/01-what-is-git.md
git status
```

The file appears in red again: it is no longer staged, but the change is still in the working directory. Since we don't want it, we discard it completely as before:

```bash
git checkout chapters/01-what-is-git.md
```

In modern versions of Git you will see that `git status` suggests `git restore <file>` and `git restore --staged <file>`. They do exactly the same as `git checkout <file>` and `git reset HEAD <file>`, but with clearer names, so you can use whichever you prefer.

## 2.4 Customizing the history and creating aliases

To give the history a bit more content, we are going to add a second chapter with the commands we have seen so far. Create `chapters/02-first-commands.md`:

````markdown
# First commands

To create a repository and save the first change:

```bash
git init
git add README.md
git commit -m "First commit"
```

`git status` shows the state of the files and `git log`, the history.
````

And save it with a commit:

```bash
git add -A
git commit -m "Add chapter 2: first commands"
```

`git log` shows a lot of information per commit, and with three commits the output is already getting long. Some options make it more visual. For example, `--graph` draws the branches as a graph on the left:

```bash
git log --graph
```

For its part, `--pretty=oneline` shows each commit on a single line, with the full hash:

```bash
git log --graph --pretty=oneline
```

And this is the most useful combination for everyday work: `--decorate` shows where the branches and tags are, `--all` shows every branch (not just the current one) and `--oneline` shortens the hash to 7 characters:

```bash
git log --graph --decorate --all --oneline
```

The output will look something like this:

```text
* 3f2a1b9 (HEAD -> main) Add chapter 2: first commands
* 8c4d2e7 Add chapter 1: what is Git
* 1a9f0c3 Add the book README
```

Throughout the course we will draw the history in diagrams like this one, which represents the same output:

```{.dot caption="History with three commits on the main branch" alt="Three chained commits, from the README to chapter 2. The main branch points to the last one and HEAD points to main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  c1 [label="1a9f0c3 Add the book README"]; c2 [label="8c4d2e7 Add chapter 1: what is Git"]; c3 [label="3f2a1b9 Add chapter 2: first commands"]
  c1 -> c2 -> c3
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c3 -> main -> HEAD [class=ref dir=back] }
}
```

Each box is a commit, with its message, and the most recent one is at the top, as in `git log`. The arrows join each commit to the next one, in the order they were created: internally, each commit stores which commit came before it, its _parent_, and that is how the history is chained together. On the right, in green, is the `main` branch, a name that points to the latest commit, and `HEAD`, in orange, shows where we are: on the `main` branch. This is what `git log` sums up as `(HEAD -> main)`.

Since typing that command every time is tedious, it is worth creating an **alias**, that is, a Git command of your own that stands for a longer one. We will call it `tree`:

```bash
git config --global alias.tree "log --graph --decorate --all --oneline"
```

From now on, `git tree` shows the history in this format, and we will use it throughout the course.

## 2.5 Ignoring unwanted files (.gitignore)

It is time to convert the book to Word. For that you need Pandoc (and Typst, if you want the PDF): if you don't have them yet, install them following the [Appendix: example dependencies](09-appendix-example-dependencies.md). Remember that they are not part of Git and are only needed to generate the book. The first step is to create `metadata.yaml`, with the details Pandoc will put on the cover:

```yaml
title: Git Handbook
subtitle: What I learned in the Git and GitHub course
author: Your Name
lang: en-US
```

Next, create the `build.sh` script, which generates the book in three formats inside a `dist` folder:

```bash
#!/usr/bin/env bash
# Generates the Git Handbook in Word, PDF and HTML from the chapters
set -euo pipefail

VERSION="${1:-}"
NAME="git-handbook${VERSION:+-$VERSION}"
OPTIONS=(--metadata-file=metadata.yaml --toc)

mkdir -p dist

pandoc "${OPTIONS[@]}" chapters/*.md -o "dist/$NAME.docx"
echo "Generated dist/$NAME.docx"

if command -v typst > /dev/null; then
  pandoc "${OPTIONS[@]}" chapters/*.md --pdf-engine=typst -o "dist/$NAME.pdf"
  echo "Generated dist/$NAME.pdf"
else
  echo "Warning: Typst is not installed, so the PDF is not generated" >&2
fi

pandoc "${OPTIONS[@]}" chapters/*.md --standalone --embed-resources -o dist/index.html
echo "Generated dist/index.html"
```

These are the main parts of the script:

- `set -euo pipefail` stops the script as soon as any command fails, instead of carrying on as if nothing had happened.
- `VERSION` is an optional argument. If you run `./build.sh v1.0.0`, the files will be called `git-handbook-v1.0.0.docx` and `git-handbook-v1.0.0.pdf`. Module 8 uses it to publish versions.
- `chapters/*.md` takes all the chapters in alphabetical order. That is why they are numbered with two digits: `01`, `02`…
- `--toc` adds a table of contents at the beginning of the book.
- The PDF is only generated if Typst is installed. If not, the script warns you and carries on.
- `index.html` is a web version of the book in a single file, which is published on GitHub Pages in module 8.

To be able to run the script, you first have to give it execute permission:

```bash
chmod +x build.sh
./build.sh
```

Open `dist/git-handbook.docx` with Word or LibreOffice: there is your book, with a cover, a table of contents and the two chapters. However, all this has left new files in the folder, so let's see what Git thinks of them:

```bash
git status
```

Git shows `metadata.yaml`, `build.sh` and the `dist/` folder as new, and here a problem arises. The first two are the book's source code and must be saved, but `dist/` contains generated files: they can be recreated at any time with `./build.sh`, they take up space and they change every time, so there is no point in versioning them. What we want is for Git to stop offering us that folder.

That is what the `.gitignore` file is for: a list of paths and patterns that Git must ignore. We start by creating it:

```bash
touch .gitignore
# From here on, edit the file adding paths or patterns, e.g. *.log or .DS_Store
```

Open `.gitignore` with your editor and write:

```text
# Book generated by build.sh
dist/

# Word and LibreOffice temporary files
~$*.docx
.~lock.*

# Operating system files
.DS_Store
Thumbs.db
```

Each line is a pattern: `dist/` ignores the whole folder, `*` is a wildcard that stands for any text and lines starting with `#` are comments. Let's check the effect:

```bash
git status
```

`dist/` has disappeared from the list. By the way, there is no need to write `.gitignore` files from scratch: GitHub maintains templates for almost any language, editor and operating system in [github/gitignore](https://github.com/github/gitignore), which you can copy and adapt. Now we can save the script, the metadata and the `.gitignore` itself, which must also be versioned so that it applies to every copy of the project:

```bash
git add -A
git commit -m "Add the script that generates the book with Pandoc"
```

## 2.6 Viewing differences between versions

Before making a commit it is a good idea to check exactly what has changed, and to practice that we need a pending change. Add a paragraph at the end of `chapters/01-what-is-git.md`, separated from the previous one by a blank line, like every paragraph in Markdown:

```markdown
Git was created in 2005 by Linus Torvalds to develop the Linux kernel.
```

Before saving it, we ask Git to show us the differences:

```bash
git diff
```

The output shows the modified file and, below it, the added lines in green with a `+` in front (removed lines would appear in red with a `-`). Keep in mind that `git diff` compares the working directory with the staging area, so if you stage the change and repeat the command, you will see nothing. To review what is already staged, use `--staged`:

```bash
git add -A
git diff
git diff --staged
```

When you are happy with the change, save it:

```bash
git commit -m "Add the origin of Git to chapter 1"
```

With this we know how to create a repository, save changes, undo them, read the history and generate the book. The commands in this module cover a good part of everyday work with Git; if you forget one, look it up in the [Git cheat sheet](https://git-scm.com/cheat-sheet) from section 1.2. In the next module we will learn to travel through that history.
