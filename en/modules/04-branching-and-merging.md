# Module 4: Branching and merging

Until now, our work has moved forward in a straight line, with every commit on the `main` branch. **Branches** let you open parallel lines of work, whether to write a new chapter without touching the stable version of the book, to try out ideas or to let several people work at once. In this module we are going to write chapters in branches and merge them, resolve our first conflict and set aside half-finished work when something urgent comes up.

Branches are much easier to understand when you see them move. If you want to practice beyond the book, [Learn Git Branching](https://learngitbranching.js.org) offers interactive exercises that draw the history with every command you type, from the first commits to the rebase in module 7.

## 4.1 Creating and switching between branches

A branch is nothing more than a named pointer to a commit, which moves forward every time a commit is made on it, and `main` is a branch like any other. To see this with our book, we are going to write chapter 3, which is precisely about branches, on a branch of its own. We start by creating it:

```bash
git branch chapter-branches
git tree
```

```text
* 852e4f5 (HEAD -> main, chapter-branches) Explain in the README how to generate the book
* 7bbac28 (tag: v0.1.0) Revert "Rewrite chapter 2"
...
```

Both branches point to the same commit, but the current branch is still `main` (`HEAD -> main`), because creating a branch doesn't mean switching to it. Remember that your identifiers will be different from the ones in the example. If you run `git branch` without arguments, you will also see the list of branches, with an asterisk next to the current one:

```{.dot caption="Newly created branch: two branches on the same commit" alt="main and chapter-branches point to the same commit, and HEAD points to main"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…"]; c5 [label="7bbac28 Revert \"Rewrite chapter 2\""]; c6 [label="852e4f5 Explain in the README how\nto generate the book"]
  e -> c5 -> c6
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="chapter-branches"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; c6 -> main -> HEAD [class=ref dir=back] }
  { rank=same; cr -> c6 [class=ref dir=forward] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

To work on the new branch we have to switch to it, and for that we use `git switch`:

```bash
git switch chapter-branches
```

Now on `chapter-branches`, create `chapters/03-branches.md` with this content:

```markdown
# Branches

A branch is an independent line of work. It lets you develop changes without affecting the main branch, `main`, until they are finished.

- `git branch <name>` creates a branch.
- `git switch <name>` switches to that branch.
- `git merge <name>` merges that branch into the current one.
```

And save it with a commit on the new branch:

```bash
git add -A
git commit -m "Add chapter 3: branches"
```

A branch usually gathers several commits before it is considered finished, so we are going to keep writing on it. Add one more line at the end of the chapter's list:

```markdown
- `git branch` shows the branches, with an asterisk next to the current one.
```

And save it in a second commit, also on the branch:

```bash
git add -A
git commit -m "Add how to list branches to chapter 3"
git tree
```

```text
* cf013da (HEAD -> chapter-branches) Add how to list branches to chapter 3
* 3b59d7e Add chapter 3: branches
* 852e4f5 (main) Explain in the README how to generate the book
* 7bbac28 (tag: v0.1.0) Revert "Rewrite chapter 2"
...
```

The output shows that `chapter-branches` is two commits ahead of `main`. This happens because, when you make a commit, only the current branch (the one `HEAD` points to) moves forward, while the others stay where they were. Since the history is still a straight line, `git tree` still draws every commit in a single column; in the diagram, on the other hand, we place the branch's commits on the right so that you can see the line of work that comes out of `main`:

```{.dot caption="chapter-branches moves forward with its commits and main stays behind" alt="From the README commit, where main is, a line goes off to the right with the two chapter 3 commits. chapter-branches and HEAD point to the last one"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c5 [label="7bbac28 Revert \"Rewrite chapter 2\"" group=main]; c6 [label="852e4f5 Explain in the README how\nto generate the book" group=main]; c7 [label="3b59d7e Add chapter 3: branches" group=ramas]; c8 [label="cf013da Add how to list branches\nto chapter 3" group=ramas]
  e -> c5 -> c6
  c6 -> c7 -> c8
  hueco1 [style=invis group=main label="852e4f5 Explain in the README how\nto generate the book"]; hueco2 [style=invis group=main label="852e4f5 Explain in the README how\nto generate the book"]
  c6 -> hueco1 -> hueco2 [style=invis]
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="chapter-branches"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; hueco1 -> c7 [style=invis] }
  { rank=same; c8 -> cr -> HEAD [class=ref dir=back] }
  { rank=same; c6 -> main [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

We can check that the branches really are independent by going back to `main` and looking at which chapters there are:

```bash
git switch main
ls chapters
```

Chapter 3 isn't there, because it only exists on its branch. However, `main` doesn't have to stand still in the meantime: the book is still alive and we can keep improving it there. Suppose that, while chapter 3 is being written on its branch, we notice that chapter 2 is missing `git diff`. Add this paragraph at the end of `chapters/02-first-commands.md`, separated from the previous one by a blank line:

```markdown
`git diff` shows the changes that haven't been saved yet.
```

And save it with a commit, this time on `main`:

```bash
git add -A
git commit -m "Add git diff to chapter 2"
git tree
```

```text
* 112a731 (HEAD -> main) Add git diff to chapter 2
| * cf013da (chapter-branches) Add how to list branches to chapter 3
| * 3b59d7e Add chapter 3: branches
|/
* 852e4f5 Explain in the README how to generate the book
* 7bbac28 (tag: v0.1.0) Revert "Rewrite chapter 2"
...
```

Now `git tree` does draw two lines coming out of the same commit: on the left, `main` with the chapter 2 commit, and on the right, `chapter-branches` with the two chapter 3 commits. Each branch has commits that the other one doesn't, which is why we say the two branches have **diverged**. Each one moves forward on its own, and what happens on one doesn't affect the other:

```{.dot caption="main and chapter-branches move forward separately" alt="Two lines come out of the README commit: on the left, the chapter 2 commit, with main and HEAD; on the right, the two chapter 3 commits, with chapter-branches"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c5 [label="7bbac28 Revert \"Rewrite chapter 2\"" group=main]; c6 [label="852e4f5 Explain in the README how\nto generate the book" group=main]; c9 [label="112a731 Add git diff to chapter 2" group=main]; c7 [label="3b59d7e Add chapter 3: branches" group=ramas]; c8 [label="cf013da Add how to list branches\nto chapter 3" group=ramas]
  e -> c5 -> c6 -> c9
  c6 -> c7 -> c8
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="chapter-branches"]; HEAD [class=head]; v010 [class=etiqueta label="v0.1.0"]
  { rank=same; HEAD -> main -> c9 [class=ref dir=forward] }
  { rank=same; c9 -> c7 [style=invis] }
  { rank=same; c8 -> cr [class=ref dir=back] }
  { rank=same; c5 -> v010 [class=ref dir=back] }
}
```

By the way, a very common shortcut is `git switch -c <name>`, which creates the branch and switches to it in a single step. In older documentation you will also see `git checkout <branch>` and `git checkout -b <branch>`, which do the same.

## 4.2 Merging branches

Chapter 3 is finished, so it is time to bring it into the book. To merge two branches you have to be on the one that receives the changes, in our case `main`, where we already are, and name the branch you want to bring in:

```bash
# From the main (receiving) branch
git merge chapter-branches
```

Since the two branches have diverged, Git has to combine their changes in a new commit, so it opens the editor with a message already written, _Merge branch 'chapter-branches'_. Save and close the editor to accept it, and you will see this output:

```text
Merge made by the 'ort' strategy.
 chapters/03-branches.md | 8 ++++++++
 1 file changed, 8 insertions(+)
 create mode 100644 chapters/03-branches.md
```

The output sums up what has arrived from the branch: the whole of chapter 3, with what its two commits added. Git hasn't asked us anything, because each branch had changed different files, chapter 2 on `main` and chapter 3 on `chapter-branches`, and there was nothing to decide. If you run `ls chapters`, you will see the three chapters, and chapter 2 keeps the `git diff` paragraph. Now let's see what the history looks like:

```bash
git tree
```

```text
*   c1ecec8 (HEAD -> main) Merge branch 'chapter-branches'
|\
| * cf013da (chapter-branches) Add how to list branches to chapter 3
| * 3b59d7e Add chapter 3: branches
* | 112a731 Add git diff to chapter 2
|/
* 852e4f5 Explain in the README how to generate the book
...
```

The new commit is a **merge commit**, and what sets it apart from the others is that it has two parents: the last commit on `main` and the last one on `chapter-branches`. It is the point where the two lines of history join up again, as you can see in the output and in the diagram. `main` (and `HEAD` with it) moves forward to the merge, while `chapter-branches` stays where it was:

```{.dot caption="The merge commit joins main and chapter-branches" alt="The commit Merge branch chapter-branches has two parents: the chapter 2 commit and the last chapter 3 commit. main and HEAD point to the merge, and chapter-branches stays on its last commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c6 [label="852e4f5 Explain in the README how\nto generate the book" group=main]; c9 [label="112a731 Add git diff to chapter 2" group=main]; c7 [label="3b59d7e Add chapter 3: branches" group=ramas]; c8 [label="cf013da Add how to list branches\nto chapter 3" group=ramas]; m1 [label="c1ecec8 Merge branch 'chapter-branches'" group=main]
  e -> c6 -> c9 -> m1
  c6 -> c7 -> c8 -> m1
  node [shape=plaintext, group=""]
  main [class=rama]; cr [class=rama label="chapter-branches"]; HEAD [class=head]
  { rank=same; m1 -> main -> HEAD [class=ref dir=back] }
  { rank=same; c9 -> c7 [style=invis] }
  { rank=same; c8 -> cr [class=ref dir=back] }
}
```

Not every merge creates a merge commit. If we had merged the branch before the chapter 2 commit, with `main` still on the README commit, as in the first diagram with the two chapter 3 commits, there would have been nothing to combine, because `main` had no commit that the branch didn't have. In that case, Git simply moves `main` forward to the last commit on the branch, without creating any new commit, and the output of `git merge` says _Fast-forward_. This is what usually happens when nobody has touched `main` while we were working on a branch, and the history stays in a straight line, as if the commits had been made directly on `main`.

In both merges, Git has managed to combine everything without help. What remains is to see what happens when it can't, and that is what we will do in the next section.

## 4.3 Resolving conflicts

Git knows how to merge changes in different files automatically, as we have just seen, and even in different parts of the same file. But if two branches change the same lines, Git can't know which version is the right one and asks someone to decide: this is what is called a **conflict**. There are no special commands to resolve it: you just edit the conflicting file, save it and finish the merge with `add` and `commit`.

To see a conflict we need two branches that change the same line in different ways, so we are going to cause one: we will change the book's title on a new branch and then change that same title in a different way on `main`. In addition, the branch will have a second change that doesn't clash with anything, so that we can see how Git separates what it can merge from what it can't. We start with the branch:

```bash
git switch -c title-change
```

On it, edit `metadata.yaml` and change the title line to:

```yaml
title: Git Handbook for Beginners
```

And save the change in a commit:

```bash
git add -A
git commit -m "Change the book title"
```

The title also appears on the first line of `README.md`, so we change it there too so that both match:

```markdown
# Git Handbook for Beginners
```

And we save it in a second commit:

```bash
git add -A
git commit -m "Put the new title in the README"
```

Now we go back to `main` to change the title in `metadata.yaml` in a different way:

```bash
git switch main
```

In `metadata.yaml`, this time change the title to:

```yaml
title: Practical Git Handbook
```

And save it in a commit too:

```bash
git add -A
git commit -m "Change the title to Practical Handbook"
git tree
```

```text
* d75c28a (HEAD -> main) Change the title to Practical Handbook
| * 0a7610b (title-change) Put the new title in the README
| * 4a61dfa Change the book title
|/
*   c1ecec8 Merge branch 'chapter-branches'
|\
| * cf013da (chapter-branches) Add how to list branches to chapter 3
| * 3b59d7e Add chapter 3: branches
* | 112a731 Add git diff to chapter 2
...
```

We now have the scenario: the two branches have diverged again, as in the previous section, but this time the commit on `main` and the first one on `title-change` change the same line of `metadata.yaml`. The diagram shows the situation:

```{.dot caption="main and title-change have diverged" alt="Two lines come out of the chapter-branches merge: on the left, Change the title to Practical Handbook, with main and HEAD; on the right, the two title-change commits"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c9 [label="112a731 Add git diff to chapter 2" group=main]; c8 [label="cf013da Add how to list branches\nto chapter 3" group=ramas]; m1 [label="c1ecec8 Merge branch 'chapter-branches'" group=main]; t3 [label="d75c28a Change the title to Practical Handbook" group=main]; t1 [label="4a61dfa Change the book title" group=titulo]; t2 [label="0a7610b Put the new title in the README" group=titulo]
  e -> c9 -> m1 -> t3
  e -> c8 -> m1
  m1 -> t1 -> t2
  node [shape=plaintext, group=""]
  main [class=rama]; ct [class=rama label="title-change"]; cr [class=rama label="chapter-branches"]; HEAD [class=head]
  { rank=same; HEAD -> main -> t3 [class=ref dir=forward] }
  { rank=same; t3 -> t1 [style=invis] }
  { rank=same; t2 -> ct [class=ref dir=back] }
  { rank=same; c9 -> c8 [style=invis] }
  { rank=same; c8 -> cr [class=ref dir=back] }
}
```

What we want now is to bring `title-change` into `main` and end up with a single title. Let's see what happens if we try to merge the branch as in the previous section:

```bash
git merge title-change
```

```text
Auto-merging metadata.yaml
CONFLICT (content): Merge conflict in metadata.yaml
Automatic merge failed; fix conflicts and then commit the result.
```

Git doesn't know which title to keep, so the merge is left halfway. To see where it stands, we check the status:

```bash
git status
```

```text
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Changes to be committed:
        modified:   README.md

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   metadata.yaml
```

The output separates the two files. `README.md` is under _Changes to be committed_: the change only came from the branch, so Git has merged it without help and left it staged for the commit. `metadata.yaml`, on the other hand, is under _Unmerged paths_ as _both modified_, because both branches have changed the same line. In other words, Git only asks for our help with what it can't combine. If you open `metadata.yaml`, you will see that it has marked the conflicting area with the two versions:

```text
<<<<<<< HEAD
title: Practical Git Handbook
=======
title: Git Handbook for Beginners
>>>>>>> title-change
subtitle: What I learned in the Git and GitHub course
author: Your Name
lang: en-US
```

- Between `<<<<<<< HEAD` and `=======` is the version from the current branch (`main`).
- Between `=======` and `>>>>>>> title-change` is the version from the branch being merged.

Resolving the conflict means leaving the file the way we want it and deleting the three marker lines. We can keep the version from the current branch, the one from the incoming branch or a mix of both. In this example we keep the one from `title-change`, because it is the title that has already reached the README with the merge:

```yaml
title: Git Handbook for Beginners
subtitle: What I learned in the Git and GitHub course
```

Editors like VS Code show buttons (_Accept Current_, _Accept Incoming_, _Accept Both_) that do this for you; in our case, the right one is _Accept Incoming_. Once the file is clean, all that is left is to mark it as resolved by adding it to the staging area and finish the merge with a commit:

```bash
git add metadata.yaml
git commit
git tree
```

As in the previous section, `git commit` opens the editor with the message _Merge branch 'title-change'_ already written, so you just save and close it. Afterwards, `git tree` shows the result:

```text
*   cf02aa6 (HEAD -> main) Merge branch 'title-change'
|\
| * 0a7610b (title-change) Put the new title in the README
| * 4a61dfa Change the book title
* | d75c28a Change the title to Practical Handbook
|/
*   c1ecec8 Merge branch 'chapter-branches'
|\
| * cf013da (chapter-branches) Add how to list branches to chapter 3
| * 3b59d7e Add chapter 3: branches
* | 112a731 Add git diff to chapter 2
...
```

The two lines of history join in the new merge commit, whose parents are the title commit on `main` and the last one on `title-change`. In the history of `main`, the result has the same shape as the merge in the previous section; the difference is that this time we have had to decide part of the content ourselves:

```{.dot caption="The merge commit joins main and title-change after resolving the conflict" alt="The commit Merge branch title-change has two parents: Change the title to Practical Handbook and Put the new title in the README. main and HEAD point to the merge"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c9 [label="112a731 Add git diff to chapter 2" group=main]; c8 [label="cf013da Add how to list branches\nto chapter 3" group=ramas]; m1 [label="c1ecec8 Merge branch 'chapter-branches'" group=main]; t3 [label="d75c28a Change the title to Practical Handbook" group=main]; t1 [label="4a61dfa Change the book title" group=titulo]; t2 [label="0a7610b Put the new title in the README" group=titulo]; m2 [label="cf02aa6 Merge branch 'title-change'" group=main]
  e -> c9 -> m1 -> t3 -> m2
  e -> c8 -> m1
  m1 -> t1 -> t2 -> m2
  node [shape=plaintext, group=""]
  main [class=rama]; ct [class=rama label="title-change"]; cr [class=rama label="chapter-branches"]; HEAD [class=head]
  { rank=same; m2 -> main -> HEAD [class=ref dir=back] }
  { rank=same; t3 -> t1 [style=invis] }
  { rank=same; t2 -> ct [class=ref dir=back] }
  { rank=same; c9 -> c8 [style=invis] }
  { rank=same; c8 -> cr [class=ref dir=back] }
}
```

If, in the middle of a conflict, you would rather abandon the merge and go back to how things were before, you can do so with `git merge --abort`.

## 4.4 Temporarily saving unfinished work (stash)

For this section we are going to reproduce a very common situation: we are in the middle of some work and something urgent comes up on another branch. The half-finished work will be chapter 4, about history and time travel, and the emergency, a typo in the README. We start the chapter on its own branch, with its title and a first commit:

```bash
git switch -c chapter-history
echo "# Time travel" > chapters/04-history.md
git add -A
git commit -m "Start chapter 4: history"
```

We keep writing. Add this paragraph at the end of `chapters/04-history.md`, with a blank line between the title and the paragraph, but this time don't commit:

```markdown
With `git checkout <commit>` you can visit any earlier version of the project.
```

We now have the scenario: the new paragraph is an uncommitted change on the chapter's branch. Suppose that right at this moment a typo turns up in the `README.md` on `main` that has to be fixed straight away. The problem is that it isn't a good idea to make a commit with the chapter half done, but neither is it a good idea to carry those unfinished changes over to `main`. What we need is to put them aside for a moment, and that is what the **stash** is for: a drawer where you park uncommitted changes.

```bash
git stash
git status
```

`git status` says there is nothing to commit, because the changes are saved in the stash and the working directory is clean. If you like, you can see what is in the drawer:

```bash
git stash list
```

```text
stash@{0}: WIP on chapter-history: 7a2c9e1 Start chapter 4: history
```

With the chapter safe, we can now deal with the emergency. Switch to `main`, fix the typo (for example, change _A book written_ to _A practical book written_ in `README.md`) and save the fix:

```bash
git switch main
git add -A
git commit -m "Fix the README"
```

With the typo fixed, we go back to the chapter's branch and take the changes out of the drawer:

```bash
git switch chapter-history
git stash pop
```

`git stash pop` applies the last saved changes and removes them from the stash, so the paragraph is back where we left it. Now we can finish the chapter with its commit and merge it into `main`:

```bash
git add -A
git commit -m "Finish chapter 4: history"
git switch main
git merge chapter-history
```

Since `main` had moved forward with the README fix, this time there is no fast-forward: Git creates a merge commit and opens the editor so that you can confirm its message. Save and close the editor to finish, and look at the history:

```bash
git tree
```

```text
*   09f9e15 (HEAD -> main) Merge branch 'chapter-history'
|\
| * 89dcf4e (chapter-history) Finish chapter 4: history
| * 7a2c9e1 Start chapter 4: history
* | 8b182a8 Fix the README
|/
*   cf02aa6 Merge branch 'title-change'
...
```

Notice that the stash leaves no trace in the history, where only the commits remain:

```{.dot caption="Merging chapter-history after fixing the README on main" alt="Two lines come out of the title-change merge: Fix the README on main and the two chapter 4 commits on chapter-history. They join in a merge commit, which main points to"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; m1 [label="cf02aa6 Merge branch 'title-change'" group=main]; r [label="8b182a8 Fix the README" group=main]; h1 [label="7a2c9e1 Start chapter 4: history" group=historial]; h2 [label="89dcf4e Finish chapter 4: history" group=historial]; m2 [label="09f9e15 Merge branch 'chapter-history'" group=main]
  e -> m1 -> r -> m2
  m1 -> h1 -> h2 -> m2
  node [shape=plaintext, group=""]
  main [class=rama]; ch [class=rama label="chapter-history"]; HEAD [class=head]
  { rank=same; m2 -> main -> HEAD [class=ref dir=back] }
  { rank=same; h2 -> ch [class=ref dir=back] }
  { rank=same; r -> h1 [style=invis] }
}
```

Sometimes, however, you park something that turns out not to be needed. To see this, make any change to `README.md`, save it to the stash and discard it:

```bash
git stash
git stash list
git stash drop
```

`git stash drop` deletes the last stash without applying it. Bear in mind, too, that by default `git stash` only saves changes to files that Git already tracks; if you also want to save new untracked files, use `git stash -u`.

## 4.5 Deleting finished branches

The branches `chapter-branches`, `title-change` and `chapter-history` have already been merged into `main`: their work is part of the book and we no longer need them. We delete them to keep the repository tidy:

```bash
git branch -d chapter-branches
git branch -d title-change
git branch -d chapter-history
git tree
```

```text
*   09f9e15 (HEAD -> main) Merge branch 'chapter-history'
|\
| * 89dcf4e Finish chapter 4: history
| * 7a2c9e1 Start chapter 4: history
* | 8b182a8 Fix the README
|/
*   cf02aa6 Merge branch 'title-change'
|\
| * 0a7610b Put the new title in the README
| * 4a61dfa Change the book title
* | d75c28a Change the title to Practical Handbook
|/
*   c1ecec8 Merge branch 'chapter-branches'
|\
| * cf013da Add how to list branches to chapter 3
| * 3b59d7e Add chapter 3: branches
* | 112a731 Add git diff to chapter 2
|/
* 852e4f5 Explain in the README how to generate the book
...
```

Deleting a branch doesn't delete its commits, which are still in the history of `main`: only the branch name, that is, the pointer, disappears. For safety, `git branch -d` refuses to delete a branch whose changes haven't been merged; if you really want to throw that work away, use `git branch -D <branch_name>`.

This is what the history of the whole module looks like, now without the branches:

```{.dot caption="History of module 4 after deleting the branches" alt="History of the module: three lines of work, the chapter 3 one, the title one and the chapter 4 one, leave main and come back to it in three merge commits. Only main and HEAD remain, on the last commit"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; c6 [label="852e4f5 Explain in the README how\nto generate the book" group=main]; c9 [label="112a731 Add git diff to chapter 2" group=main]; c7 [label="3b59d7e Add chapter 3: branches" group=ramas]; c8 [label="cf013da Add how to list branches\nto chapter 3" group=ramas]; m1 [label="c1ecec8 Merge branch 'chapter-branches'" group=main]; t3 [label="d75c28a Change the title to Practical Handbook" group=main]; t1 [label="4a61dfa Change the book title" group=titulo]; t2 [label="0a7610b Put the new title in the README" group=titulo]; m2 [label="cf02aa6 Merge branch 'title-change'" group=main]; r [label="8b182a8 Fix the README" group=main]; h1 [label="7a2c9e1 Start chapter 4: history" group=historial]; h2 [label="89dcf4e Finish chapter 4: history" group=historial]; m3 [label="09f9e15 Merge branch 'chapter-history'" group=main]
  e -> c6 -> c9 -> m1 -> t3 -> m2 -> r -> m3
  c6 -> c7 -> c8 -> m1
  m1 -> t1 -> t2 -> m2
  m2 -> h1 -> h2 -> m3
  node [shape=plaintext, group=""]
  main [class=rama]; HEAD [class=head]
  { rank=same; m3 -> main -> HEAD [class=ref dir=back] }
  { rank=same; c9 -> c7 [style=invis] }
  { rank=same; t3 -> t1 [style=invis] }
  { rank=same; r -> h1 [style=invis] }
}
```

Our book now has four chapters, but it still lives only on your computer. In the next module we will upload it to GitHub.
