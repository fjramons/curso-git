# Module 3: Time travel and save points

The commit history isn't just a record of what we have done: it is a time machine. In this module we are going to make use of it in three ways. First we will visit earlier versions of the book without changing anything; then we will see two ways of undoing a whole commit, either by removing it from the branch (with the option of getting it back if we change our minds) or by canceling it out with a new commit; and, finally, we will mark the first version of the book with a tag so that we can go back to it whenever we want.

## 3.1 Navigating to earlier states of the project

Let's start with the simplest thing: looking at the past without touching it. Suppose we want to see what the book looked like when it only had chapter 1, before chapter 2 and the Pandoc script arrived. To travel to that moment we need to know which commit it corresponds to, so we look for it in the history:

```bash
git tree
```

```text
* 5e7b3a2 (HEAD -> main) Add the origin of Git to chapter 1
* 9d1c4f8 Add the script that generates the book with Pandoc
* 3f2a1b9 Add chapter 2: first commands
* 8c4d2e7 Add chapter 1: what is Git
* 1a9f0c3 Add the book README
```

The one we are interested in is the commit _Add chapter 1: what is Git_, which in the example is `8c4d2e7`. The syntax is `git checkout <commit_id>`, which takes the project to that commit:

```bash
git checkout 8c4d2e7
```

Your identifiers will be different from the ones in the example, so use the one that appears in your `git tree`.

Git replies with a warning about _detached HEAD_. It isn't an error: it means that `HEAD`, the pointer that shows where we are, no longer points to a branch but directly to an old commit. It is a read-only mode in which we can look at everything we like, so let's check that we really have traveled to the past:

```bash
ls chapters
git tree
```

```text
* 5e7b3a2 (main) Add the origin of Git to chapter 1
* 9d1c4f8 Add the script that generates the book with Pandoc
* 3f2a1b9 Add chapter 2: first commands
* 8c4d2e7 (HEAD) Add chapter 1: what is Git
* 1a9f0c3 Add the book README
```

Only `01-what-is-git.md` is left in `chapters`, and neither `build.sh` nor `metadata.yaml` exist: the files have gone back exactly to the state of that commit. `git tree`, for its part, shows that `HEAD` is on the old commit while `main` is still on the latest one, which is what the diagram shows:

```{.dot caption="Detached HEAD: HEAD points to a commit, not to a branch" alt="Five commits. main points to the last one and HEAD points directly to the chapter 1 commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  c1 [label="1a9f0c3 Add the book README"]; c2 [label="8c4d2e7 Add chapter 1: what is Git"]; c3 [label="3f2a1b9 Add chapter 2: first commands"]; c4 [label="9d1c4f8 Add the script that generates\nthe book with Pandoc"]; c5 [label="5e7b3a2 Add the origin of Git to chapter 1"]
  c1 -> c2 -> c3 -> c4 -> c5
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c5 -> main [class=ref dir=back] }
  { rank=same; c2 -> HEAD [class=ref dir=back] }
}
```

Once our curiosity is satisfied, we return to the present by switching back to the `main` branch:

```bash
git checkout main
```

Everything is back as it was. It is worth knowing, though, that this mode is for looking and not for working: if you make changes and commits in _detached HEAD_, they are not lost at that moment, but they don't belong to any branch and will end up disappearing. If you want to keep them, create a branch before leaving (we will see how in module 4).

## 3.2 Removing changes permanently (`reset --hard`)

Sometimes looking at the past isn't enough: you need to go back to it and forget what came afterwards. To see this, we first need a mistake to regret, so we are going to make one on purpose: we will replace chapter 2 with placeholder content and save it in a commit, as if it were a real change.

```bash
echo "# Chapter under construction" > chapters/02-first-commands.md
git add -A
git commit -m "Rewrite chapter 2"
```

We now have the scenario. If you run `git tree`, you will see the bad commit on top of all the others:

```text
* b4e8d61 (HEAD -> main) Rewrite chapter 2
* 5e7b3a2 Add the origin of Git to chapter 1
* 9d1c4f8 Add the script that generates the book with Pandoc
* 3f2a1b9 Add chapter 2: first commands
* 8c4d2e7 Add chapter 1: what is Git
* 1a9f0c3 Add the book README
```

The diagram shows the top part of that history, with `main` and `HEAD` on the bad commit:

```{.dot caption="The bad commit is the last one on main" alt="Three commits. The last one, Rewrite chapter 2, has main and HEAD on it"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="9d1c4f8 Add the script that generates\nthe book with Pandoc"]; c5 [label="5e7b3a2 Add the origin of Git to chapter 1"]; c6 [label="b4e8d61 Rewrite chapter 2"]
  e -> c4 -> c5 -> c6
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c6 -> main -> HEAD [class=ref dir=back] }
}
```

Suppose that, on rereading the chapter, we decide the previous version was much better and that this commit should never have existed. What we want, then, is for `main`, and `HEAD` with it, to go back one commit to _Add the origin of Git to chapter 1_, and for the files to be as they were in that commit.

That is exactly the job of `git reset --hard`, which moves the current branch to the commit you give it and leaves the working directory exactly as it was in that commit. Its syntax is `git reset --hard <commit_id>`, so all we need is the identifier of the commit we want to go back to. In the example, according to the `git tree` output and the diagram, it is `5e7b3a2`:

```bash
git reset --hard 5e7b3a2
```

Your identifier will be different: use the one that appears in your `git tree` next to _Add the origin of Git to chapter 1_. Chapter 2 has its content back, and to see what has happened to the history we look at it again:

```bash
git tree
```

```text
* 5e7b3a2 (HEAD -> main) Add the origin of Git to chapter 1
* 9d1c4f8 Add the script that generates the book with Pandoc
* 3f2a1b9 Add chapter 2: first commands
* 8c4d2e7 Add chapter 1: what is Git
* 1a9f0c3 Add the book README
```

`main` and `HEAD` are now on `5e7b3a2`, and the bad commit has disappeared from the list: for all practical purposes, we have deleted it. The diagram shows what the history looks like:

```{.dot caption="After git reset --hard, the bad commit has disappeared from main" alt="main and HEAD point to the commit Add the origin of Git to chapter 1, which is the last one again"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="9d1c4f8 Add the script that generates\nthe book with Pandoc"]; c5 [label="5e7b3a2 Add the origin of Git to chapter 1"]
  e -> c4 -> c5
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c5 -> main -> HEAD [class=ref dir=back] }
}
```

`git reset --hard` is a powerful operation, but also a dangerous one: changes that weren't saved in any commit are lost forever. What's more, it should only be used with commits we haven't yet shared with anyone; in section 3.3 we will see the alternative for those that are already shared.

As a curiosity, the deleted commit hasn't completely disappeared: Git keeps it hidden for a while, and that makes it possible to recover it if we deleted it by accident. We will see this in the advanced section that follows, but for everyday work it is enough to think of `reset --hard` as deleting commits.

On the other hand, when something goes wrong with Git, chances are it has happened to many people before. The website [Oh Shit, Git!?!](https://ohshitgit.com) collects the most common situations (a commit on the wrong branch, a badly written message, a forgotten file…) and the exact command to fix each one.

### 3.2.1 Advanced: recovering a deleted commit (`reflog`)

This section is advanced, so you can skip it on a first reading and come back to it the day you delete by mistake a commit you actually wanted. When it is over, the book will be exactly as it was at the start.

We said that `reset --hard` deletes the commit, but that isn't really true. What it does is move the branch: the commit _Rewrite chapter 2_ is still stored in the repository, with all its content, only there is no longer any branch that leads to it. Since `git log` and `git tree` only show the commits that can be reached from a branch or from `HEAD`, the commit is still there, but hidden and lost. The diagram shows the real situation, with that commit in gray and with a dashed outline, which is how we will draw commits that have been left outside every branch throughout the course:

```{.dot caption="The deleted commit is still in the repository, outside every branch" alt="main and HEAD point to the commit Add the origin of Git to chapter 1. The commit Rewrite chapter 2 is still above it, in gray, with a dashed outline and no branch"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="9d1c4f8 Add the script that generates\nthe book with Pandoc"]; c5 [label="5e7b3a2 Add the origin of Git to chapter 1"]; c6 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="b4e8d61 Rewrite chapter 2"]
  e -> c4 -> c5; c5 -> c6 [class=huerfano style=dashed color=gray50]
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c5 -> main -> HEAD [class=ref dir=back] }
}
```

The fact that the commit is still stored opens an interesting door. Suppose we change our minds and want to get it back. The problem is that it no longer appears in `git log` or in `git tree`, so we don't have its identifier at hand. To find it we turn to `git reflog`, which shows every movement of `HEAD`, including commits, checkouts and resets:

```bash
git reflog
```

```text
5e7b3a2 (HEAD -> main) HEAD@{0}: reset: moving to 5e7b3a2
b4e8d61 HEAD@{1}: commit: Rewrite chapter 2
5e7b3a2 (HEAD -> main) HEAD@{2}: checkout: moving from 8c4d2e7f1a6b9c03d5e2847a1f6c9b0e3d7a2f5c to main
...
```

There is the commit _Rewrite chapter 2_. Each line is a movement, from the most recent to the oldest: `HEAD@{0}` is the reset we have just done, `HEAD@{1}` is the lost commit and `HEAD@{2}` is the return to `main` from section 3.1, where Git notes down the full identifier of the commit we were coming from. With the identifier of the lost commit in hand (`b4e8d61` in the example, the gray commit in the diagram), getting it back is as simple as doing another `reset --hard`, this time to it:

```bash
git reset --hard b4e8d61
```

As before, use the identifier that appears in your `reflog`. The commit is back on `main`, as in the first diagram of the section, which shows that the reset hadn't destroyed it. Since that commit was really unnecessary, we finish by repeating the first `reset --hard` to leave the book as it was, although this time without having to copy any identifier:

```bash
git reset --hard HEAD~1
```

`HEAD~1` means "the commit before `HEAD`", which is exactly where we want to take the branch. If you run `git tree`, you will see that the last commit is once again _Add the origin of Git to chapter 1_.

This safety net has its limits, though. The `reflog` is local (it isn't uploaded to GitHub), and a lost commit is only kept as long as the `reflog` remembers it: by default, Git forgets those entries after 30 days (those for other movements, after 90) and then removes the lost commits in its periodic cleanup. Recovering a commit with `reflog` is a remedy for accidents, not a substitute for making commits.

## 3.3 Undoing a commit without rewriting history (`revert`)

`reset` solves the problem by making commits disappear from the branch, that is, by rewriting history. As long as those commits are only on our computer, that is fine, but from module 5 onwards the book will be on GitHub and other people will have copies of the history. If a commit that other people already have disappears from our branch, our history and theirs no longer match.

`git revert` undoes a commit in a different way: instead of deleting it, it creates a new commit that applies the opposite changes. The original commit stays in the history and the new one cancels it out, so the history only grows and is never rewritten.

The best way to appreciate the difference is to face the same problem as in the previous section and solve it the other way. So we are going to repeat the mistake exactly, with the same content and the same message:

```bash
echo "# Chapter under construction" > chapters/02-first-commands.md
git add -A
git commit -m "Rewrite chapter 2"
```

We are back at the starting point: the last commit on `main` empties chapter 2 and we want to undo it. The difference is that this time we want to do it without the commit disappearing from the history, as if we had already shared it. Since the commit we want to cancel is the last one, `HEAD` is enough to refer to it:

```bash
git revert HEAD
```

Git prepares the commit that undoes the changes and opens the editor with a suggested message. Below the message you will see some comment lines starting with `#`, which are not saved:

```text
Revert "Rewrite chapter 2"

This reverts commit 7c1e5b8a3f9d2e6c4b1a0f8e7d5c3b2a9e6f4d10.
```

The message says which commit is being undone, with its full identifier, so we can accept it as it is: save and close the editor without changing anything. If you would rather the editor didn't open, `git revert --no-edit HEAD` accepts the suggested message directly. Chapter 2 has its content back, and to see what has happened to the history we look at it again:

```bash
git tree
```

```text
* 7bbac28 (HEAD -> main) Revert "Rewrite chapter 2"
* 7c1e5b8 Rewrite chapter 2
* 5e7b3a2 Add the origin of Git to chapter 1
* 9d1c4f8 Add the script that generates the book with Pandoc
* 3f2a1b9 Add chapter 2: first commands
* 8c4d2e7 Add chapter 1: what is Git
* 1a9f0c3 Add the book README
```

Unlike what happened with `reset`, `git tree` shows both commits, the bad one and the one that cancels it:

```{.dot caption="git revert adds a commit that cancels the previous one" alt="After the commit Add the origin of Git to chapter 1 come the commit Rewrite chapter 2 and the Revert commit that cancels it. main and HEAD point to the Revert commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="5e7b3a2 Add the origin of Git to chapter 1"]; c6 [label="7c1e5b8 Rewrite chapter 2"]; c7 [label="7bbac28 Revert \"Rewrite chapter 2\""]
  e -> c5 -> c6 -> c7
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; c7 -> main -> HEAD [class=ref dir=back] }
}
```

If we compare this diagram with the one in section 3.2, the difference is obvious: there the bad commit disappeared from the branch, and here it is still on `main`, with another commit on top that cancels it. All that remains is to check that the content is the same as before the mistake, and to do that we compare the current state with the one from two commits back (`HEAD~2`), as in section 2.6:

```bash
git diff HEAD~2
```

`git diff` shows nothing, which confirms that the files are identical to those of the commit _Add the origin of Git to chapter 1_. The table summarizes the two ways of undoing a commit that we have seen:

| | `git reset --hard` | `git revert` |
| --- | --- | --- |
| What it does | Moves the branch to an earlier commit | Creates a commit that cancels another one |
| History | Rewritten: the commits disappear from the branch | Preserved: a commit is only added |
| When to use it | With commits that are only on your computer | With commits you have already shared |

All this leads to a simple rule of thumb: if nobody else has the commit, you can use `reset`; if you have already shared it, use `revert`. In section 7.4 we will come back to `revert` to undo a change that will already have reached GitHub.

## 3.4 Tags for marking important versions

After so much coming and going, the book now has two chapters and a script that generates it, so it is a good time to declare a first draft that we can always go back to when needed. That is what **tags** are for: they give a fixed name to a specific commit, usually a version number. Unlike a branch, a tag doesn't move when new commits are made.

In the course we will use the usual [semantic versioning](https://semver.org) format with a `v` in front, so our first draft will be `v0.1.0`. We create it on the current commit:

```bash
git tag v0.1.0
```

And we can see the list of tags in the repository with:

```bash
git tag
```

Tags also appear in `git tree`, next to the commit they point to. However, as long as the book doesn't move forward it is hard to appreciate what sets them apart from a branch, so we are going to keep working beyond `v0.1.0`. Add a section to `README.md` that explains how to generate the book:

````markdown
## How to generate the book

You need Pandoc (and, optionally, Typst for the PDF). Run:

```bash
./build.sh
```

The book is generated in the `dist` folder.
````

And save the change with a commit:

```bash
git add -A
git commit -m "Explain in the README how to generate the book"
git tree
```

```text
* 852e4f5 (HEAD -> main) Explain in the README how to generate the book
* 7bbac28 (tag: v0.1.0) Revert "Rewrite chapter 2"
* 7c1e5b8 Rewrite chapter 2
* 5e7b3a2 Add the origin of Git to chapter 1
* 9d1c4f8 Add the script that generates the book with Pandoc
* 3f2a1b9 Add chapter 2: first commands
* 8c4d2e7 Add chapter 1: what is Git
* 1a9f0c3 Add the book README
```

The output and the diagram show just what we wanted to see: `main` has moved forward with the new commit, but the tag, in ochre in the diagram, has stayed on its commit:

```{.dot caption="The v0.1.0 tag stays put when main moves forward" alt="The v0.1.0 tag points to the commit Revert Rewrite chapter 2, and main and HEAD to the next commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c4 [label="7c1e5b8 Rewrite chapter 2"]; c5 [label="7bbac28 Revert \"Rewrite chapter 2\""]; c6 [label="852e4f5 Explain in the README how\nto generate the book"]
  e -> c4 -> c5 -> c6
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c6 -> main -> HEAD [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

That is what tags are good for. Imagine someone asks you for the book exactly as it was in version `v0.1.0`. The README has changed since then, but there is no need to look for the commit in the history or remember its identifier: just travel to the tag and generate the book from there, passing the version to the script:

```bash
git checkout tags/v0.1.0
./build.sh v0.1.0
```

In `dist` you will now find `git-handbook-v0.1.0.docx` (and the PDF, if you have Typst). It may come as a surprise that the generated files are still there when you switch versions, but there is a reason: Git doesn't touch files it doesn't control, such as those in `dist/`, which is also in the `.gitignore`. With the document generated, we return to the present:

```bash
git checkout main
```

The tags we have created this way are _lightweight_: just a name that points to a commit. Git also supports _annotated_ tags, which also store an author, a date and a message (`git tag -a v0.1.0 -m "First draft"`). In module 7 we will use annotated tags to mark each version of the book, and in module 8 GitHub will use them to publish those versions automatically.
