# Module 6: Collaboration and open source

Until now, our book has had a single author. In this module we are going to open the door to other people with the workflow used in almost every open source project: someone makes a copy of the project in their own account (_fork_), proposes changes (_pull request_) and the person in charge reviews and accepts them. Then we will see how to keep that copy up to date and, to finish, we will go over the Markdown syntax the book is written in.

## 6.1 Forks and pull requests

For this section you need a partner. One of you will act as the **author** (the owner of the `git-handbook` repository) and the other as the **collaborator**, who is going to write chapter 5 of the author's book. Afterwards you can swap roles.

If you are taking the course on your own, you can create a second GitHub account for the collaborator. Bear in mind that GitHub doesn't allow the same SSH key on two accounts, so the second account will need its own key (repeat section 5.1 with a different file name).

Before starting, it is worth understanding the problem that forks solve. A collaborator doesn't have permission to `push` to the author's repository, so they need somewhere else to store their work. That place is the **fork**: a complete copy of someone else's repository inside their own GitHub account, where they can write. From the fork, the collaborator proposes their changes to the original repository through a **pull request** (PR), that is, a request for the author to review the changes and, if they look good, merge them.

The whole journey has three stages: the collaborator creates the fork and writes the chapter in it, opens the pull request and, finally, the author reviews and merges it. We start on the collaborator's side.

**Collaborator**: go to the author's repository (`https://github.com/<author>/git-handbook`) and press the _Fork_ button at the top right. Accept the default options and press _Create fork_. In a few seconds you will have `https://github.com/<collaborator>/git-handbook`, with the whole history of the author's book.

To work on the fork you need a local copy, so clone it (the fork, not the author's repository) with the SSH URL from the _Code_ button. It is a good idea to do it in a folder with a different name, so as not to confuse it with your own book:

```bash
cd ~/projects
git clone <your_fork_url> git-handbook-fork
cd git-handbook-fork
```

When collaborating, it is good practice not to work directly on `main`, but on a branch with a descriptive name. That way the PR contains only that work and your `main` stays the same as the author's:

```bash
git switch -c chapter-github
```

On that branch, write chapter 5 in `chapters/05-github.md`:

```markdown
# GitHub

GitHub is a platform that hosts Git repositories in the cloud and adds tools for collaboration.

- A **remote** is a copy of the repository somewhere else, such as GitHub.
- `git push` uploads commits to the remote and `git pull` downloads them.
- A **fork** is a copy of someone else's repository in your account.
- A **pull request** is a proposal of changes for another person to review.
```

Before proposing the change, check that the book still builds correctly with `./build.sh`. Then save and push your work as usual:

```bash
git add -A
git commit -m "My collaborative contribution: chapter 5 on GitHub"
git push -u origin chapter-github
```

Since the branch is new, `-u` creates it on your fork and links it. If the collaborator had worked directly on `main`, `git push` would be enough.

The chapter is now on the fork, but not yet in the author's book: for it to get there, you have to open the pull request. A yellow notice now appears on your fork's page on GitHub, _chapter-github had recent pushes_; press _Compare & pull request_. GitHub shows what is going to be merged and where:

- **base repository**: `<author>/git-handbook`, branch `main`. This is the destination.
- **head repository**: `<collaborator>/git-handbook`, branch `chapter-github`. This is the source.

Write a clear title (_Add chapter 5 on GitHub_) and a description that explains what the change brings, and press _Create pull request_.

Now the ball is in the author's court.

**Author**: in your repository, the _Pull requests_ tab shows the new PR. Open it and review it:

- The _Files changed_ tab shows the diff of the change. You can press the `+` that appears next to any line to leave a comment.
- With the _Review changes_ button you can approve the PR (_Approve_), ask for changes (_Request changes_) or just comment.

If you ask for changes, the collaborator can make them on their `chapter-github` branch, commit and `git push`, and the new commits will be added automatically to the same PR, with no need to open another one.

When everything is fine, press _Merge pull request_ and then _Confirm merge_. The button has an arrow with three options: _Create a merge commit_ (the usual one, which keeps all the commits and creates a merge commit), _Squash and merge_ (combines all the PR's commits into a single one) and _Rebase and merge_ (places the commits on top of `main` without a merge commit). For now, we will use the first one.

Chapter 5 is now part of the book on GitHub. To have it locally too, the author just has to download it:

```bash
cd ~/projects/git-handbook
git pull
```

If you want to repeat this process with a real project, the [First Contributions](https://github.com/firstcontributions/first-contributions) repository is designed precisely for making a first pull request: it explains step by step, in many languages, how to make a fork, a change and a pull request that someone will actually review.

## 6.2 Synchronizing forks (Sync fork) and resolving conflicts on the web

A fork is an independent copy, so when the original repository moves forward, the fork doesn't update itself. Right now, for instance, the `main` branch of the collaborator's fork has neither the PR's merge commit nor the changes the author has made since. Before starting a new contribution, the collaborator should bring their fork up to date; otherwise, they will be working on an old version and will have more conflicts.

To see this, we are going to make the original move forward a little more. The **author** makes a change to their book: for example, they edit `chapters/01-what-is-git.md` from the GitHub website, add a line at the end and commit it to `main`:

```markdown
Git is free and open source software.
```

We now have the scenario: the author's repository has several commits that the fork doesn't have, and we want to bring it up to date.

**Collaborator**: go to your fork's page. Above the list of files you will see a message like _This branch is 3 commits behind `<author>/git-handbook:main`_ (the chapter 5 commit, the PR's merge commit and the author's change). Press the _Sync fork_ button and then _Update branch_, and GitHub will copy the original's new commits into your fork's `main`. This whole process is done on the website, with no need for the terminal.

Your fork on GitHub is now up to date, but your local copy isn't yet. We update it as with any other remote change and, while we are at it, delete the chapter's branch, which has already been merged:

```bash
cd ~/projects/git-handbook-fork
git switch main
git pull
git branch -d chapter-github
```

If you would rather synchronize from the terminal without going through the website, add the original repository as a second remote, which by convention is called `upstream`, and download its changes:

```bash
git remote add upstream <author_repository_ssh_url>
git fetch upstream
git merge upstream/main
git push
```

As you can see, the collaborator works with three copies of the book. The diagram sums up how changes travel between them:

```{.dot caption="The author's repository, the fork and the collaborator's local copy" alt="The fork is created from the author's repository and brought up to date with Sync fork. The local copy pushes changes to the fork with git push and gets them with git pull or with git fetch upstream. The changes go back to the author's repository with a pull request"}
digraph {
  rankdir=TB; nodesep=1.2; ranksep=0.7
  autor [class=repo label="<author>/git-handbook\n(upstream)"]
  fork [class=repo label="<collaborator>/git-handbook\n(origin)"]
  local [class=repo label="git-handbook-fork\n(local copy)"]
  { rank=same; autor; fork }
  autor -> fork [class=accion label="Fork\nSync fork"]
  fork -> autor [class=accion label="Pull request"]
  fork -> local [class=accion label="git pull "]
  local -> fork [class=accion label=" git push"]
  autor -> local [class=accion label="git fetch upstream  "]
}
```

The collaborator's changes only reach the author's repository through a pull request, because the collaborator doesn't have permission to write to it.

**Conflicts in a PR**. There is one last case to look at: what happens if, while a PR is open, someone changes the same lines on `main` as the PR. In that situation GitHub can't merge it automatically. To cause it, the collaborator creates a new branch on their fork, changes the `title:` line in `metadata.yaml` and opens a PR; meanwhile, the author changes that same line on their `main` from the website.

As a result, on the PR page, instead of the green merge button, the message _This branch has conflicts that must be resolved_ appears. What we want is to resolve the conflict without leaving GitHub, and if it is simple, we can: the _Resolve conflicts_ button opens a web editor with the conflicting file and the same markers as in section 4.3 (`<<<<<<<`, `=======` and `>>>>>>>`):

1. Edit the file until it looks the way it should and delete the markers.
2. Press _Mark as resolved_ (if there are several conflicting files, repeat for each one).
3. Press _Commit merge_. GitHub creates a merge commit on the PR's branch and the merge button is available again. The author can now merge the PR as in section 6.1.

If the conflict is complex, on the other hand, GitHub will ask you to resolve it locally: bring the branch to your computer, run `git merge main` (or `git merge upstream/main` from a fork), resolve the conflict as in section 4.3 and `git push`.

## 6.3 Using Markdown (README.md)

**Markdown** is a lightweight markup language: plain text with a few symbols that indicate the formatting. It is easy to read even without converting it, it works very well with Git (diffs show exactly what has changed, which doesn't happen with a `.docx`) and GitHub displays it formatted automatically. That is why `README.md` is the front page of any repository, and why our book is written in Markdown.

As with Git commands, there is no need to memorize the syntax: the [Markdown Guide](https://www.markdownguide.org/) explains each element with examples and its [cheat sheet](https://www.markdownguide.org/cheat-sheet/) sums them up on one page.

This is the syntax you will use most:

````markdown
# Level 1 heading

## Level 2 heading

### Level 3 heading

A paragraph is a block of text. It is separated from the next one by a blank line.

Text in **bold**, in _italics_ and `inline code`.

- An item in a list
- Another item
  - Nested item (with two spaces in front)

1. First step
2. Second step

[Link text](https://git-scm.com)

![Alternative text for the image](https://git-scm.com/images/logo.png)

> A quote or a highlighted note.

```bash
git status
```

| Command | What it is for |
| --- | --- |
| `git add` | Stages changes |
| `git commit` | Saves changes |
````

A few details are worth keeping in mind:

- Headings structure the document. In the book, each chapter starts with a single level 1 heading (`#`), which Pandoc turns into a chapter and uses to build the table of contents.
- Always state the language of code blocks (`bash`, `yaml`, `markdown`…). GitHub and Pandoc use it to highlight the syntax.
- GitHub adds extras to Markdown, such as task lists (`- [ ] To do` and `- [x] Done`) and alerts (`> [!NOTE]`). Pandoc also has its own, such as footnotes (`Text[^1]` and, further down, `[^1]: Content of the note`). Use them with care if you want the text to look the same in both places. GitHub's extras are explained in [Writing on GitHub](https://docs.github.com/en/get-started/writing-on-github), in its documentation.

Let's apply this to make the book's `README.md` a good front page.

**Author**: before editing, bring into your local copy the commits you made on the website in the previous section. If you don't, your `main` and GitHub's will diverge and GitHub will reject the `git push`:

```bash
cd ~/projects/git-handbook
git pull
```

With the copy up to date, replace the contents of your `README.md` with this:

````markdown
# Git Handbook for Beginners

A practical book about Git and GitHub, written in Markdown during the Git and GitHub course.

## Contents

1. What is Git?
2. First commands
3. Branches
4. Time travel
5. GitHub

## How to generate the book

You need [Pandoc](https://pandoc.org) and, if you want the PDF, [Typst](https://typst.app). Run:

```bash
./build.sh
```

The book is generated in the `dist` folder in Word, PDF and HTML format.

## How to contribute

1. Fork this repository.
2. Create a branch for your change.
3. Open a pull request with a description of what you are contributing.
````

Then save the change and push it:

```bash
git add -A
git commit -m "Improve the README with the contents and how to contribute"
git push
```

If you open the repository on GitHub, you will see the README formatted below the list of files. While you write, you can see a preview of any Markdown file in VS Code with `Ctrl+Shift+V` (`Cmd+Shift+V` on macOS).

Besides the README, open source projects usually have a `LICENSE` file with the license, which states what other people may do with the content: copy it, modify it, publish it… Without a license, nobody has legal permission to reuse the project, even if it is public. Our book doesn't need one, but if you publish a project of your own, GitHub's [choosealicense.com](https://choosealicense.com/) will help you choose the right one.
