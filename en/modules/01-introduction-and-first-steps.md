# Module 1: Introduction and first steps

In this course we are going to learn Git and GitHub by building a real project: a **Git Handbook** written in Markdown. Every new concept we see will go into the book and, at the end, a script will convert it to Word, PDF and HTML with Pandoc, while GitHub publishes each version automatically.

This first module prepares the ground. We will see what Git and GitHub are, how to install Git, how to move around the terminal and how to set up the identity we will sign our commits with.

## 1.1 What is Git and what is GitHub?

Anyone who works on a document or a software project ends up, sooner or later, with files like `book-final.docx`, `book-final-v2.docx` and `book-final-REALLY-FINAL.docx`. A **version control system** solves this problem: it keeps a complete history of the changes, records who changed what and when, and lets you go back to any earlier point.

**Git** is the most widely used version control system in the world, and it has three features worth knowing from the start:

- **It is local**: it works entirely on your computer, without an internet connection. The full history lives in a hidden `.git` folder inside your project.
- **It is distributed**: every copy of the project has the full history, not just the latest version. No central server is essential.
- **It works with snapshots**: every time you save (what is called _making a commit_), Git takes a picture of the state of all the files in the project.

**GitHub**, for its part, is a web platform that hosts Git repositories in the cloud. Besides storing a copy of your project, it adds everything needed to collaborate: user and permission management, change review (_pull requests_), issue tracking (_issues_), automation (_GitHub Actions_) and website publishing (_GitHub Pages_). The table summarizes the differences:

| | Git | GitHub |
| --- | --- | --- |
| What it is | Version control program | Web hosting platform |
| Where it runs | On your computer | On the internet |
| Needs a connection | No | Yes |
| Alternatives | Mercurial, SVN | GitLab, Bitbucket, Gitea (all use Git) |

Following this distinction, in modules 2 to 4 we will work only with Git, locally, and from module 5 onwards we will upload the book to GitHub.

## 1.2 Installing Git and checking versions

The first step is to install Git with the method for your operating system.

On **Linux** (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install git
```

On **macOS**, with [Homebrew](https://brew.sh):

```bash
brew install git
```

If you don't use Homebrew, macOS will offer to install Git along with Apple's developer tools the first time you type `git` in the terminal.

On **Windows**, from PowerShell:

```powershell
winget install --id Git.Git -e
```

You can also download the installer from [git-scm.com](https://git-scm.com/downloads).

The Git installer for Windows includes **Git Bash**, a terminal that understands the same commands as Linux and macOS. So, if you use Windows, always open Git Bash to follow the course: that way every command will work the same.

Once it is installed, close and reopen the terminal so that it picks up the new program, and check that Git responds:

```bash
git --version
git -v
```

Both commands are equivalent and show something like `git version 2.43.0`. If you see `command not found` instead, the installation didn't work or the terminal hasn't been restarted.

Git has hundreds of options, so it is normal not to remember them. When that happens, you can ask Git itself for help:

```bash
git --help
git -h
```

Both show the most common Git commands, grouped by task. You can also ask for help on a specific command, for example `git commit -h` (short summary) or `git help commit` (full manual).

That said, the fact that Git has hundreds of options doesn't mean you have to learn them all. Throughout the course we will see many commands, but there is no need to memorize them: what matters is understanding what each one does and when it is worth using. A few of them (`git status`, `git add`, `git commit`, `git log`, `git switch`, `git pull` and `git push`) are used every day, and you will end up knowing them by heart without trying. For the rest, it is enough to know that they exist and what they are for; you look up the exact syntax when you need it, just as professionals do.

For those lookups you have these references at hand, and their addresses are worth saving in your browser bookmarks:

- **Git cheat sheet**, at <https://git-scm.com/cheat-sheet>. It gathers the most common commands on a single page, grouped by task. Keep it open or print it while you follow the course.
- **Official Git website**, at <https://git-scm.com>. It includes the documentation for every command, at <https://git-scm.com/docs>, and the free book _Pro Git_, at <https://git-scm.com/book/en/v2>, to dig deeper into any topic.
- **GitHub documentation**, at <https://docs.github.com/en>. It explains everything GitHub (<https://github.com>) offers: accounts, repositories, pull requests, GitHub Actions… It will be useful from module 5 onwards.

These and the rest of the references that appear in the course are collected in the [Appendix: useful references](10-appendix-useful-references.md).

With this you have everything you need to use Git. To follow the course example, in which the book is converted to Word, PDF and HTML, you will also need two tools that have nothing to do with Git: **Pandoc** and, optionally, **Typst**. Install them following the [Appendix: example dependencies](09-appendix-example-dependencies.md) before you reach section 2.5.

## 1.3 Basic terminal navigation

Git can be used from graphical interfaces, but in this course we will work in the terminal, because that is where you really understand what is going on, and it is what you will find on any server or in any documentation. Before starting with Git, then, it is worth moving around the folders on your computer with ease, and a few commands are all it takes:

```bash
ls
cd <folder>
cd ..
pwd
mkdir <folder>
clear
```

- `ls`: lists the contents of the current folder.
- `cd <folder>`: enters a folder.
- `cd ..`: goes up to the parent folder.
- `pwd`: shows the path of the folder you are in.
- `mkdir <folder>`: creates a new folder.
- `clear`: clears the screen.

Let's put them into practice by creating the folder where our book will live. We start in the home folder (`~`) and check where we are:

```bash
cd ~
pwd
```

The output will be something like `/home/your-username` on Linux, `/Users/your-username` on macOS or `/c/Users/your-username` in Git Bash. Next, we create a `projects` folder for all your work and, inside it, the book's folder:

```bash
mkdir projects
cd projects
mkdir git-handbook
ls
```

`ls` shows the newly created `git-handbook` folder. We go into it and check the path:

```bash
cd git-handbook
pwd
```

The output ends in `projects/git-handbook`, which will be our working folder for the whole course. To practice a bit more, go up one level and come back in:

```bash
cd ..
pwd
cd git-handbook
clear
```

Finally, a trick that will save you a lot of time: type the first few letters of a folder and press the Tab key, and the terminal will complete the name.

## 1.4 Initial user setup (global)

Every commit carries its author's signature, made up of a name and an email address, so before starting you need to tell Git who you are. It is best to use the same email address you will sign up with (or already have) on GitHub, because that way GitHub can link your commits to your account:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

The `--global` option saves the settings for all of your user's repositories, in the `~/.gitconfig` file, so you only need to do this once per computer. If a particular project needs a different identity (for example, your work email), just run the same commands without `--global` inside that project.

To finish, we check that the settings have been saved:

```bash
git config --global --list
```

You should see your details on the `user.name` and `user.email` lines. With this, everything is ready to create our first repository.
