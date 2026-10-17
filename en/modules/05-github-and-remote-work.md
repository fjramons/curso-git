# Module 5: GitHub and remote work

Until now, our book has lived only on your computer: if the disk fails, everything is lost, and nobody else can read it or collaborate on it. In this module we are going to upload it to GitHub. To do so, we will first set up a secure connection with SSH, then link the local repository to a remote one and, finally, learn to synchronize changes in both directions.

If you don't have a GitHub account yet, create one at [github.com](https://github.com) with the same email address you configured in section 1.4.

## 5.1 Secure authentication with SSH

For GitHub to know that it is you uploading the changes, **SSH keys** are used. An SSH key is a pair of files:

- The **private key** stays on your computer and is never shared with anyone.
- The **public key** is uploaded to GitHub. With it, GitHub can check that whoever connects has the matching private key, without the private key ever traveling over the network.

Thanks to this mechanism you won't have to type a username and password every time you connect. The process has four steps: create the key pair, add it to the SSH agent, upload the public key to GitHub and test the connection.

We start by creating the key pair. GitHub recommends the Ed25519 algorithm, which generates shorter and more secure keys:

```bash
# Create the keys
ssh-keygen -t ed25519 -C "you@example.com"
```

Ed25519 works on Linux, on macOS and on Windows with Git Bash. Only some very old systems or company computers with security restrictions don't support it; in that case, create a 4096-bit RSA key instead:

```bash
ssh-keygen -t rsa -b 4096 -C "you@example.com"
```

`ssh-keygen` will ask you where to save the key: press Enter to accept the default path (`~/.ssh/id_ed25519`, or `~/.ssh/id_rsa` if you used RSA). Then it will ask you for a _passphrase_, which protects the private key in case someone gets into your computer. Setting one is highly recommended.

That said, typing that passphrase on every connection would be tiresome. To avoid it, we add the key to the **SSH agent**, a program that keeps it unlocked during the session. We start the agent and add the key to it:

```bash
# Start the agent and add the key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

If you used RSA, the path is `~/.ssh/id_rsa`. On macOS you can add `--apple-use-keychain` to `ssh-add` so that the system keychain remembers the passphrase.

The next step is to upload the public key to GitHub. To do so, display its contents and copy all of it (it starts with `ssh-ed25519` or `ssh-rsa`):

```bash
cat ~/.ssh/id_ed25519.pub
```

Notice that the file ends in `.pub`, because it is the public key. On GitHub, go to your profile picture → _Settings_ → _SSH and GPG keys_ → _New SSH key_, enter a title that identifies your computer (for example, _Personal laptop_), paste the key and press _Add SSH key_.

All that is left is to check that the connection works:

```bash
ssh -T git@github.com
```

The first time, SSH will ask whether you trust the server `github.com`: type `yes`. If everything is fine, you will see:

```text
Hi your-username! You've successfully authenticated, but GitHub does not provide shell access.
```

If any step fails or your system has its own quirks, the guide [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) in the GitHub documentation explains each step for Linux, macOS and Windows, and how to solve the most common errors.

## 5.2 Connecting the local repository to the remote and the first push

With authentication sorted out, we need a repository on GitHub to upload the book to. On GitHub, press the _+_ button in the top right corner → _New repository_. Call it `git-handbook`, choose whether it will be public or private and **don't tick** any option to add a README, `.gitignore` or license: all of that already exists locally, and what we need is an empty remote repository. Press _Create repository_.

GitHub then shows a page with instructions. Make sure the _SSH_ option is selected and copy the URL, which looks like this: `git@github.com:your-username/git-handbook.git`.

Now we go back to the terminal to tell our repository where its copy on GitHub is, that is, to add it as a **remote**. A remote is a copy of the repository somewhere else, identified by a short name which, by convention, is `origin` for the main remote:

```bash
cd ~/projects/git-handbook
git remote add origin <github_repository_ssh_url>
git remote -v
```

`git remote -v` shows the URL of `origin` twice: once for downloading (_fetch_) and once for uploading (_push_). With the remote configured, we can now upload the `main` branch:

```bash
git push -u origin main
```

The `-u` (`--set-upstream`) option links the local `main` branch to `main` on `origin`, so that in future Git knows where to push to and pull from without being told. If you reload the repository page on GitHub, you will see the README, the chapters and the whole history there.

There is one detail left: `git push` doesn't upload tags by default, so the `v0.1.0` we created in module 3 has stayed local. We upload it separately:

```bash
git push --tags
```

From now on, every time you make new commits on `main`, all it takes to upload them is:

```bash
git push
```

## 5.3 Synchronizing changes from the remote (fetch and pull)

Changes aren't always made from your computer: they can come from another person, another computer or the GitHub website itself. To see how they are brought into the local copy, we are going to create a change that only exists on GitHub. Open `README.md` on the website, press the pencil icon (_Edit this file_) and add at the end:

```markdown
This book is published on GitHub.
```

Press _Commit changes_, keep the suggested message and confirm. We now have the scenario: GitHub has a commit that our local repository doesn't know about. Before bringing it in, we want to find out what has changed without modifying the local files, and for that we use `git fetch`:

```bash
git fetch
git status
git tree
```

The output of `git tree` starts like this:

```text
* 71d265c (origin/main) Update README.md
*   09f9e15 (HEAD -> main) Merge branch 'chapter-history'
...
```

`git fetch` downloads the new commits from the remote, but doesn't touch the local branch. That is why `git status` warns that `main` is _behind_ `origin/main` by one commit, and `git tree` shows `origin/main` one step ahead of `main`. `origin/main` is a remote-tracking branch, that is, the local copy of how `main` was on GitHub at the last synchronization. In the diagrams it appears in purple:

```{.dot caption="After git fetch, origin/main is one commit ahead of main" alt="origin/main points to the commit Update README.md made on GitHub, and main and HEAD to the previous commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; m2 [label="09f9e15 Merge branch 'chapter-history'"]; w1 [label="71d265c Update README.md"]
  e -> m2 -> w1
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; om [class=remota label="origin/main"]
  { rank=same; w1 -> om [class=ref dir=back] }
  { rank=same; m2 -> main -> HEAD [class=ref dir=back] }
}
```

Once we have reviewed it, what we want is to bring that commit into our local branch. For that we use `git pull`, which is equivalent to a `git fetch` followed by a `git merge`:

```bash
git pull
```

The local README now has the new line and `main` has moved forward to `origin/main`, as in a fast-forward. Everything went smoothly because there were no local changes, but in practice it is common for both sides to move forward at the same time. Let's create that situation: we will make a change on GitHub and, without downloading it, a different one locally. We start with GitHub: edit `README.md` on the website again and add one more line:

```markdown
You can read it in the `chapters` folder.
```

Without downloading that change, add a paragraph locally at the end of `chapters/03-branches.md`, separated from the list by a blank line (otherwise, Markdown joins it to the last bullet):

```markdown
Branches are cheap: creating one only costs a few bytes.
```

Now we save the local change in a commit and try to bring in the GitHub one as before:

```bash
git add -A
git commit -m "Expand chapter 3"
git pull
```

This time `git pull` fails with the message _Need to specify how to reconcile divergent branches_. We now have the scenario we were looking for: the two branches have diverged, because each one has a commit the other doesn't have, and Git wants to know whether it should join them with a merge or with a rebase (rebase is explained in module 7). To see the situation, we look at the history:

```bash
git tree
```

```text
* 7f7f300 (HEAD -> main) Expand chapter 3
| * 65f4e2c (origin/main) Update README.md
|/
* 71d265c Update README.md
...
```

`main` and `origin/main` come out of the same commit, but each one has a commit of its own, as the diagram shows:

```{.dot caption="main and origin/main have diverged" alt="Two commits come out of the first Update README.md commit: Expand chapter 3, with main and HEAD, and a second Update README.md, with origin/main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=a]; a1 [label="71d265c Update README.md" group=a]; a2 [label="7f7f300 Expand chapter 3" group=a]; a3 [label="65f4e2c Update README.md" group=remota]
  e -> a1 -> a2; a1 -> a3
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; om [class=remota label="origin/main"]
  { rank=same; HEAD -> main -> a2 [class=ref dir=forward] }
  { rank=same; a3 -> om [class=ref dir=back] }
  { rank=same; a2 -> a3 [style=invis] }
}
```

The first time you have to choose, and we will go for the classic behavior, the merge:

```bash
# Usual setting if Git asks for it the first time
git config pull.rebase false
git pull
```

Git creates a merge commit and opens the editor so that you can confirm the message. Save and close the editor, and look at the history again:

```bash
git tree
```

```text
*   1fcd879 (HEAD -> main) Merge branch 'main' of github.com:your-username/git-handbook
|\
| * 65f4e2c (origin/main) Update README.md
* | 7f7f300 Expand chapter 3
|/
* 71d265c Update README.md
...
```

As you can see in the output and in the diagram, it is the same situation as in section 4.2, only with `origin/main` instead of another local branch:

```{.dot caption="git pull creates a merge commit that joins the two histories" alt="A merge commit joins Expand chapter 3 and the second Update README.md. main and HEAD point to the merge, and origin/main stays on the second Update README.md"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=d]; d1 [label="71d265c Update README.md" group=d]; d2 [label="7f7f300 Expand chapter 3" group=d]; d3 [label="65f4e2c Update README.md" group=remota]; d4 [label="1fcd879 Merge branch 'main' of\ngithub.com:your-username/git-handbook" group=d]
  e -> d1 -> d2 -> d4; d1 -> d3 -> d4
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; om [class=remota label="origin/main"]
  { rank=same; d4 -> main -> HEAD [class=ref dir=back] }
  { rank=same; d3 -> om [class=ref dir=back] }
  { rank=same; d2 -> d3 [style=invis] }
}
```

If you want to apply this preference to all your repositories, add `--global` to `git config`. Finally, we push the result, which makes `origin/main` point to the merge commit too:

```bash
git push
```

## 5.4 Cloning a remote repository locally

So far we have taken the path of uploading a repository that already existed locally. The opposite path is **cloning**: downloading a complete repository from GitHub, with its whole history and with the `origin` remote already configured. This is what you will do to work on the book from another computer or to start collaborating on someone else's project.

Since you probably don't have a second computer at hand, we are going to simulate one by cloning the book into another folder, which will pose as a "laptop". From the repository page, press the green _Code_ button, choose _SSH_ and copy the URL:

```bash
cd ~/projects
git clone <repository_ssh_url> git-handbook-laptop
cd git-handbook-laptop
```

The last argument to `git clone` is optional and sets the folder name. Without it, Git would use the repository name (`git-handbook`), which in our case already exists. Let's check that we have the whole book:

```bash
ls
git tree
```

Notice that there is no `dist` folder: it was in the `.gitignore`, so it was never uploaded, and anyone who clones the repository can generate the book with `./build.sh`. To see how a change travels from one copy to another, we are going to make one from the "laptop". Add this paragraph at the end of `chapters/04-history.md`:

```markdown
With `git reflog` you can recover commits that no longer appear in the history.
```

And push it to GitHub with its commit:

```bash
git add -A
git commit -m "Expand chapter 4 with reflog"
git push
```

The change is now on GitHub, but not on the "main computer". We go back to it and download it:

```bash
cd ~/projects/git-handbook
git pull
```

With this, the two copies are synchronized through GitHub:

```{.dot caption="Two local copies synchronized through GitHub" alt="git-handbook-laptop pushes the changes to GitHub with git push, and git-handbook downloads them with git pull"}
digraph {
  rankdir=LR
  port [class=repo label="git-handbook-laptop"]
  gh [class=repo label="GitHub: git-handbook"]
  pc [class=repo label="git-handbook"]
  port -> gh [class=accion label="  git push  "]
  gh -> pc [class=accion label="  git pull  "]
}
```

As the diagram shows, neither local copy talks directly to the other: each one synchronizes with GitHub. You can delete the `git-handbook-laptop` folder whenever you like, because the book is safe on GitHub and in your main folder.
