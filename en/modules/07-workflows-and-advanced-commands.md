# Module 7: Workflows and advanced commands

With the book now on GitHub and the first contribution merged, it is time to organize the work as in a professional project. In this module we will see what graphical interfaces offer compared with the terminal, how branches are organized with a workflow (GitFlow and GitHub flow), two commands that rewrite history (cherry-pick and rebase) and, finally, how to undo a change that is already on GitHub without rewriting it (revert).

## 7.1 Graphical interfaces (GUIs) versus the terminal

Everything we have done so far in the terminal can also be done with graphical programs. These are the best known:

| Program | Systems | Price | Strengths |
| --- | --- | --- | --- |
| [GitHub Desktop](https://desktop.github.com) | Windows, macOS | Free | Very simple, integrated with GitHub (forks, PRs) |
| [GitKraken](https://www.gitkraken.com) | Windows, macOS, Linux | Free for public repositories | Very visual branch graph, conflict resolution |
| [Sourcetree](https://www.sourcetreeapp.com) | Windows, macOS | Free | Very complete, exposes almost every Git option |
| VS Code (_Source Control_ panel) | Windows, macOS, Linux | Free | Built into the editor, ideal for writing and committing without switching windows |

Graphical interfaces are convenient for visual tasks, such as reviewing a diff, staging only some lines of a file, exploring the branch graph or resolving a conflict with buttons. However, underneath they all use the same concepts you already know: working directory, staging, commits, branches and remotes. If you don't understand those concepts, a GUI only hides what is going on; if you do, it is one more tool.

Even so, the terminal is still essential: it is the only thing available on a server, it is what all the documentation and CI systems use, and some operations (such as interactive rebase) are clearer in it. A good exercise is to open the `~/projects/git-handbook` folder with the GUI of your choice and try to recognize our book's commits, branches and tags in it.

## 7.2 Workflows: GitFlow and GitHub flow

Git lets you organize branches with complete freedom, and that is precisely why teams agree on a **workflow**: a set of rules about which branches exist and how changes move between them. The two best known are GitFlow and GitHub flow, and it is worth knowing both even though our book will follow only the second one.

**GitFlow** is designed for projects that publish numbered versions and have to maintain several at once, such as a desktop application. To do so, it uses these branches:

- `main`: contains only published versions. Every commit on `main` is a version and carries its tag.
- `develop`: integration branch where work for the next version accumulates.
- `feature/<name>`: one branch for each new feature. It comes out of `develop` and goes back to `develop`.
- `release/<version>`: prepares a version (final touches and version number). It comes out of `develop` and is merged into `main` and into `develop`.
- `hotfix/<version>`: fixes an urgent bug in a published version. It comes out of `main` and is merged into `main` and into `develop`.

GitFlow was proposed by Vincent Driessen in 2010 in the article [A successful Git branching model](https://nvie.com/posts/a-successful-git-branching-model/), which is still the best description of the workflow.

The diagram shows a general outline of GitFlow, not the history of our book. It shows how each temporary branch comes out of a permanent branch and goes back to it, while `main` only receives finished versions:

```{.dot caption="General outline of GitFlow" alt="main only receives versions. develop comes out of main and receives a feature. An urgent fix comes out of main, creates version 1.0.1 and also goes back to develop. The 1.1 release comes out of develop, creates version 1.1 on main and goes back to develop"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  m1 [label="Version 1.0" group=main]; m2 [label="Version 1.0.1" group=main]; m3 [label="Version 1.1" group=main]
  h1 [label="hotfix: fix an urgent bug" group=hotfix]
  r1 [label="release: prepare version 1.1" group=release]
  d1 [label="Start development" group=develop]; d2 [label="Integrate the feature" group=develop]; d3 [label="Integrate the fix" group=develop]; d4 [label="Integrate version 1.1" group=develop]
  f1 [label="feature: new feature" group=feature]
  m1 -> m2 -> m3
  m1 -> h1 -> m2
  m1 -> d1
  d1 -> paso [arrowhead=none headclip=false]; paso -> d2 [tailclip=false]
  d2 -> d3 -> d4
  d1 -> f1 -> d2
  h1 -> d3
  d3 -> r1 -> m3
  r1 -> d4
  node [shape=plaintext, group=""]
  develop [class=rama]; v10 [class=etiqueta label="v1.0"]; v101 [class=etiqueta label="v1.0.1"]; r3 [class=refs label="main, v1.1"]
  { rank=same; r3 -> m3 [class=ref dir=forward] }
  { rank=same; v101 -> m2 [class=ref dir=forward] }
  { rank=same; v10 -> m1 [class=ref dir=forward] }
  { rank=same; d4 -> develop [class=ref dir=back] }
  { rank=same; h1 -> d1 [style=invis] }
  paso [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=develop]
  { rank=same; m2 -> paso -> f1 [style=invis] }
  { rank=same; m3 -> d4 [style=invis] }
}
```

As the diagram shows, following GitFlow with plain Git commands requires a lot of merges. That is why there is an extension, `git-flow`, that automates them with commands such as `git flow feature start` or `git flow release finish`. It is useful in large teams with several versions under maintenance, but it adds branches and steps that a small project like ours doesn't need.

**GitHub flow** is the simple alternative, and it is the workflow our book will follow from now on. It has only one permanent branch, `main`, which must always work, and every change follows these steps:

1. A short branch is created from `main`, with a name that describes the change.
2. Commits are made on it and it is pushed to GitHub.
3. A pull request is opened so that other people can review the change.
4. When the pull request is approved, it is merged into `main` and the branch is deleted.

The GitHub documentation describes it in [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow).

In fact, we already put it into practice in module 6 with chapter 5: the `chapter-github` branch, its pull request and the merge commit that GitHub created on `main`. After downloading the merge with `git pull`, the top of `git tree` in the author's copy looked like this:

```text
*   6dce13e (HEAD -> main, origin/main) Merge pull request #1 from <collaborator>/chapter-github
|\
| * 7429b59 My collaborative contribution: chapter 5 on GitHub
|/
* 57c522f Expand chapter 4 with reflog
...
```

The diagram draws it with the branch's commit to the right of `main`:

```{.dot caption="GitHub flow: chapter 5 reached main with a pull request" alt="The chapter 5 commit, made on the chapter-github branch, comes out of the commit Expand chapter 4 with reflog. A merge commit created by the pull request joins it to main, where main, origin/main and HEAD are"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; r [label="57c522f Expand chapter 4 with reflog" group=main]; c5 [label="7429b59 My collaborative contribution:\nchapter 5 on GitHub" group=rama]; pr [label="6dce13e Merge pull request #1 from\n<collaborator>/chapter-github" group=main]
  e -> r
  r -> c5 -> pr
  paso [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco [style=invis label="" width=1.4]
  r -> paso [arrowhead=none headclip=false]; paso -> pr [tailclip=false]
  node [shape=plaintext, group=""]
  rpr [class=refs label="HEAD -> main, origin/main"]
  { rank=same; pr -> rpr [class=ref dir=back] }
  { rank=same; paso -> hueco -> c5 [style=invis] }
}
```

The author's repository doesn't have the `chapter-github` branch, which only existed on the collaborator's fork, but it keeps its commit.

We are now going to write chapter 6 of the book, which is precisely about workflows, and we will already do it with GitHub flow: on a branch of its own that we will merge with a pull request in our own repository. So as not to start from an outdated version, we first make sure we have the latest version of `main` and then create the branch:

```bash
cd ~/projects/git-handbook
git switch main
git pull
git switch -c chapter-workflows
```

On the new branch, create `chapters/06-workflows.md` with this content:

```markdown
# Workflows

A workflow is the set of rules a team follows for using branches.

- **GitFlow** uses two permanent branches, `main` and `develop`, and temporary branches for each feature, each release and each urgent fix.
- **GitHub flow** uses a single permanent branch, `main`. Each change is made on a short branch and reaches `main` with a pull request.
```

And save it with a commit:

```bash
git add -A
git commit -m "Add chapter 6: workflows"
```

With six chapters, the book is ready for its first complete version, so we use the same branch to prepare it. Add a line with the version at the end of `metadata.yaml`, which Pandoc will show on the cover below the title:

```yaml
date: Version 1.0.0
```

We save this change in another commit and push the branch to GitHub:

```bash
git add -A
git commit -m "Prepare version 1.0.0"
git push -u origin chapter-workflows
```

Now it is time to open the pull request. On the repository page on GitHub, press _Compare & pull request_ in the yellow notice. Since the branch is in your own repository, this time you don't need a fork: the pull request goes from `chapter-workflows` to `main` in the same repository. Press _Create pull request_ and, since there is nobody else to review it, merge it yourself with _Merge pull request_ and _Confirm merge_. Finally, press _Delete branch_ to delete the branch on GitHub, which is no longer needed.

In a team, someone else would review the pull request before merging it, as we did in module 6. Even if you work alone, each pull request leaves a record of the change and, in module 8, it will also let GitHub check the book automatically before merging it.

The merge is now on GitHub, but not yet in our local copy. We bring it in and delete the branch, which is already integrated into `main`:

```bash
git switch main
git pull --prune
git branch -d chapter-workflows
```

The `--prune` option also deletes `origin/chapter-workflows`, the remote-tracking branch for a branch that no longer exists on GitHub.

All that remains is to mark the version. In GitHub flow, versions are marked with tags on `main`, and in this case we will use an annotated tag, which stores an author, a date and a message (section 3.4). We create it and push it to GitHub:

```bash
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0
git tree
```

```text
*   5656f2f (HEAD -> main, tag: v1.0.0, origin/main) Merge pull request #N from your-username/chapter-workflows
|\
| * 6439eeb Prepare version 1.0.0
| * b8a12b2 Add chapter 6: workflows
|/
* 45a644f Improve the README with the contents and how to contribute
...
```

The diagram shows the result: the branch's two commits reach `main` with the pull request's merge commit, which carries the `v1.0.0` tag. `N` is the number GitHub has assigned to the pull request:

```{.dot caption="Version 1.0.0, published with GitHub flow" alt="The two commits of the chapter-workflows branch come out of the commit Improve the README. The pull request's merge commit joins them to main and carries the v1.0.0 tag"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; p [label="45a644f Improve the README with the\ncontents and how to contribute" group=main]; c6 [label="b8a12b2 Add chapter 6: workflows" group=rama]; v [label="6439eeb Prepare version 1.0.0" group=rama]; pr [label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows" group=main]
  e -> p
  p -> c6 -> v -> pr
  paso1 [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; paso2 [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco1 [style=invis label="" width=1.4]; hueco2 [style=invis label="" width=1.4]
  p -> paso1 [arrowhead=none headclip=false]; paso1 -> paso2 [arrowhead=none headclip=false tailclip=false]; paso2 -> pr [tailclip=false]
  node [shape=plaintext, group=""]
  rpr [class=refs label="HEAD -> main, origin/main, v1.0.0"]
  { rank=same; pr -> rpr [class=ref dir=back] }
  { rank=same; paso1 -> hueco1 -> c6 [style=invis] }
  { rank=same; paso2 -> hueco2 -> v [style=invis] }
}
```

## 7.3 Advanced commands: cherry-pick and rebase

**Cherry-pick** copies a specific commit from another branch onto the current branch, without bringing anything else. It is useful when a fix was made on one branch but is also needed on another.

To see it in action we need a valuable commit trapped on a branch that can't be merged yet. We are going to create that situation in a very common way: we will start chapter 7 on a new branch and, halfway through the work, make a fix to chapter 3 on that same branch which, in reality, should reach `main` as soon as possible. First, we start the chapter:

```bash
git switch -c chapter-advanced
echo "# Advanced commands" > chapters/07-advanced-commands.md
git add -A
git commit -m "Start chapter 7"
```

Now suppose that, while you are writing, you discover an inaccuracy in chapter 3. The natural thing is to fix it there and then, on the same branch: edit `chapters/03-branches.md` and replace the last line with a more precise version:

```markdown
Branches are cheap: Git stores each one in a file of only 41 bytes holding the identifier of its last commit.
```

We save the fix in its own commit and, since we are going to need it straight away, show its identifier with `git log --oneline -1`, which shows only the last commit:

```bash
git add -A
git commit -m "Clarify the size of a branch in chapter 3"
git log --oneline -1
```

```text
8d5d3fd (HEAD -> chapter-advanced) Clarify the size of a branch in chapter 3
```

We now have the scenario: the `chapter-advanced` branch contains two commits, the beginning of chapter 7 and the chapter 3 fix. And here is the problem: the fix should reach `main` now, but chapter 7 is half done and can't go with it. What we want, then, is to take only that commit to `main`, leaving the rest of the branch where it is. That is exactly what cherry-pick does, and its syntax is `git cherry-pick <commit_id>`. We create a branch from `main` and copy only that commit onto it, which in the example is `8d5d3fd`:

```bash
# Bring a specific commit to the current branch
git switch -c fix-chapter-3 main
git cherry-pick 8d5d3fd
git tree
```

Use the identifier that appears in your `git log`. The output of `git tree` is this:

```text
* 5ec836d (HEAD -> fix-chapter-3) Clarify the size of a branch in chapter 3
| * 8d5d3fd (chapter-advanced) Clarify the size of a branch in chapter 3
| * d52353a Start chapter 7
|/
*   5656f2f (tag: v1.0.0, origin/main, main) Merge pull request #N from your-username/chapter-workflows
...
```

The last argument to `git switch -c` says where the branch is created from: here, from `main` and not from the current branch. `git tree` shows a new commit on `fix-chapter-3` with the same message but a different identifier (`5ec836d` instead of `8d5d3fd`), because cherry-pick doesn't move the commit, it creates a copy. In the diagram, the dashed arrow joins the original to its copy:

```{.dot caption="Cherry-pick: a copy of the fix on a branch that comes out of main" alt="Two branches come out of the version 1.0.0 merge. On chapter-advanced are Start chapter 7 and the chapter 3 fix. On fix-chapter-3 there is a copy of that fix"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; pr [label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows" group=main]; s [label="d52353a Start chapter 7" group=avanzados]; c [label="8d5d3fd Clarify the size of a branch\nin chapter 3" group=avanzados]; c2 [label="5ec836d Clarify the size of a branch\nin chapter 3" group=corrige]
  e -> pr -> s -> c
  pr -> c2
  c -> c2 [class=copia constraint=false]
  hueco1 [style=invis group=main label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows"]; hueco2 [style=invis group=main label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows"]
  pr -> hueco1 -> hueco2 [style=invis]
  node [shape=plaintext, group=""]
  rpr [class=refs label="main, origin/main, v1.0.0"]; ca [class=rama label="chapter-advanced"]; cc [class=rama label="fix-chapter-3"]; HEAD [class=head]
  { rank=same; pr -> rpr [class=ref dir=back] }
  { rank=same; hueco1 -> s -> c2 [style=invis] }
  { rank=same; c2 -> cc -> HEAD [class=ref dir=back] }
  { rank=same; hueco2 -> c [style=invis] }
  { rank=same; c -> ca [class=ref dir=back] }
}
```

If a conflict comes up when applying the commit, Git stops as in a merge. In that case you can resolve it and continue with `git cherry-pick --continue`, or give up and return to the previous state with:

```bash
git cherry-pick --abort
```

The fix is now on its own branch, ready to be merged into `main` with GitHub flow, just as we did in the previous section. First, we push the branch:

```bash
git push -u origin fix-chapter-3
```

On GitHub, open the pull request, merge it and delete the branch. Then we update the local copy:

```bash
git switch main
git pull --prune
git branch -d fix-chapter-3
```

**Rebase** is the alternative to `merge` for integrating the changes from one branch into another. Instead of creating a merge commit, it takes the commits of the current branch and applies them again, one by one, on top of the other branch. The result is a linear history, as if the work had started after the latest changes.

To see rebase we need two branches that have diverged, and we are already halfway there: `main` has moved forward with the merge of the fix, while `chapter-advanced` still comes out of version 1.0.0. To make the divergence more noticeable, we are going to keep writing chapter 7 with a couple of commits. We first go back to its branch:

```bash
git switch chapter-advanced
```

Add a paragraph about cherry-pick to the chapter, separated from the title by a blank line:

```markdown
`git cherry-pick <commit>` copies a specific commit from another branch onto the current branch.
```

And save it with its commit:

```bash
git add -A
git commit -m "Add cherry-pick to chapter 7"
```

Next, add another paragraph about rebase, also with a blank line before it:

```markdown
`git rebase <branch>` reapplies the commits of the current branch on top of another branch.
```

We save it with another commit and look at what the history looks like:

```bash
git add -A
git commit -m "Add rebase to chapter 7"
git tree
```

```text
* ea70d95 (HEAD -> chapter-advanced) Add rebase to chapter 7
* d1dfabd Add cherry-pick to chapter 7
* 8d5d3fd Clarify the size of a branch in chapter 3
* d52353a Start chapter 7
| * af8bb0b (origin/main, main) Merge pull request #N from your-username/fix-chapter-3
|/|
| * 5ec836d Clarify the size of a branch in chapter 3
|/
*   5656f2f (tag: v1.0.0) Merge pull request #N from your-username/chapter-workflows
...
```

We now have the scenario we were looking for: `git tree` shows that `main` and `chapter-advanced` have diverged. On one side, `main` has the merge of the fix; on the other, `chapter-advanced` has the chapter 7 commits and the original fix:

```{.dot caption="main and chapter-advanced have diverged" alt="Two lines come out of the version 1.0.0 merge. On main, the chapter 3 fix arrives with a pull request. On chapter-advanced are the chapter 7 commits and the original fix"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  a0 [label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows" group=main]; ac [label="5ec836d Clarify the size of a branch\nin chapter 3" group=corrige]; am [label="af8bb0b Merge pull request #N from\nyour-username/fix-chapter-3" group=main]
  a1 [label="d52353a Start chapter 7" group=a]; a2 [label="8d5d3fd Clarify the size of a branch\nin chapter 3" group=a]; a3 [label="d1dfabd Add cherry-pick to chapter 7" group=a]; a4 [label="ea70d95 Add rebase to chapter 7" group=a]
  a0 -> ac -> am
  a0 -> a1 -> a2 -> a3 -> a4
  paso [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco [style=invis label="" width=1.4]
  a0 -> paso [arrowhead=none headclip=false]; paso -> am [tailclip=false]
  node [shape=plaintext, group=""]
  ram [class=refs label="main, origin/main"]; ca1 [class=rama label="chapter-advanced"]; head1 [class=head label="HEAD"]; v1a [class=etiqueta label="v1.0.0"]
  { rank=same; ram -> am [class=ref dir=forward] }
  { rank=same; a4 -> ca1 -> head1 [class=ref dir=back] }
  { rank=same; a0 -> v1a [class=ref dir=back] }
  { rank=same; paso -> hueco -> ac -> a1 [style=invis] }
  { rank=same; am -> a2 [style=invis] }
}
```

We want to bring the branch up to date with `main`, but without the merge commit a merge would create. Rebase, on the other hand, reapplies the branch's commits on top of the last commit on `main`:

```bash
# Move the current branch onto another one (rebase)
git rebase main
git tree
```

```text
* c7f2e18 (HEAD -> chapter-advanced) Add rebase to chapter 7
* 9a3d5f2 Add cherry-pick to chapter 7
* e41b07c Start chapter 7
*   af8bb0b (origin/main, main) Merge pull request #N from your-username/fix-chapter-3
|\
| * 5ec836d Clarify the size of a branch in chapter 3
|/
*   5656f2f (tag: v1.0.0) Merge pull request #N from your-username/chapter-workflows
...
```

Git warns that it has skipped a commit (_skipped previously applied commit_): the chapter 3 fix is already on `main` thanks to the cherry-pick, so it doesn't apply it again. Now the history is a straight line, with the three chapter 7 commits after the merge of the fix. Notice that their identifiers have changed (_Start chapter 7_, for example, has gone from `d52353a` to `e41b07c`): just like cherry-pick, rebase creates new copies of the commits. The originals, in gray and with a dashed outline in the diagram, are no longer on any branch, like the commit deleted with `reset` in section 3.2.1:

```{.dot caption="The chapter-advanced branch after git rebase main" alt="The copies of the three chapter 7 commits are on top of the merge of the fix. The repeated fix disappears and the original commits are left in gray, with a dashed outline"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  d0 [label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows" group=main]; dc [label="5ec836d Clarify the size of a branch\nin chapter 3" group=lado]; dm [label="af8bb0b Merge pull request #N from\nyour-username/fix-chapter-3" group=main]
  d1 [label="e41b07c Start chapter 7" group=lado]; d2 [label="9a3d5f2 Add cherry-pick to chapter 7" group=lado]; d3 [label="c7f2e18 Add rebase to chapter 7" group=lado]
  o1 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="d52353a Start chapter 7" group=huerfanos]; o2 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="8d5d3fd Clarify the size of a branch\nin chapter 3" group=huerfanos]; o3 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="d1dfabd Add cherry-pick to chapter 7" group=huerfanos]; o4 [class=huerfano style="rounded,dashed" color=gray50 fontcolor=gray50 label="ea70d95 Add rebase to chapter 7" group=huerfanos]
  dm -> d1 -> d2 -> d3
  d0 -> dc -> dm
  d0 -> o1 [class=huerfano style=dashed color=gray50]; o1 -> o2 [class=huerfano style=dashed color=gray50]; o2 -> o3 [class=huerfano style=dashed color=gray50]; o3 -> o4 [class=huerfano style=dashed color=gray50]
  paso1 [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco1 [style=invis label="" width=1.4]; hueco3 [style=invis group=main label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows"]; hueco4 [style=invis group=main label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows"]; hueco5 [style=invis group=main label="5656f2f Merge pull request #N from\nyour-username/chapter-workflows"]
  d0 -> paso1 [arrowhead=none headclip=false]; paso1 -> dm [tailclip=false]
  dm -> hueco3 -> hueco4 -> hueco5 [style=invis]
  node [shape=plaintext, group=""]
  rdm [class=refs label="main, origin/main"]; ca2 [class=rama label="chapter-advanced"]; head2 [class=head label="HEAD"]; v1d [class=etiqueta label="v1.0.0"]
  { rank=same; rdm -> dm [class=ref dir=forward] }
  { rank=same; d0 -> v1d [class=ref dir=back] }
  { rank=same; paso1 -> hueco1 -> dc -> o1 [style=invis] }
  { rank=same; dm -> o2 [style=invis] }
  { rank=same; hueco3 -> d1 -> o3 [style=invis] }
  { rank=same; hueco4 -> d2 -> o4 [style=invis] }
  { rank=same; hueco5 -> d3 [style=invis] }
  { rank=same; d3 -> ca2 -> head2 [class=ref dir=back] }
}
```

**Interactive rebase** goes further: it lets you reorder, edit, combine or delete commits before integrating them. Our branch gives us a good reason to use it, because the three chapter 7 commits are intermediate steps that add nothing to the book's history. Ideally the chapter would reach `main` as a single commit, so we are going to combine them:

```bash
git rebase -i main
```

Git opens the editor with the list of commits that are going to be reapplied, from oldest to newest:

```text
pick e41b07c Start chapter 7
pick 9a3d5f2 Add cherry-pick to chapter 7
pick c7f2e18 Add rebase to chapter 7
```

To fold the last two into the one before, change `pick` to `squash` (or simply `s`) on those two lines:

```text
pick e41b07c Start chapter 7
squash 9a3d5f2 Add cherry-pick to chapter 7
squash c7f2e18 Add rebase to chapter 7
```

Save and close the editor. Git then opens another editor with the three messages, which will be combined into one: replace them with `Add chapter 7: advanced commands`, save and close. If you now run `git tree`, you will see a single commit for the chapter.

If a rebase gets complicated (for example, with conflicts in several commits in a row), you can cancel it at any time and return to the previous state:

```bash
git rebase --abort
```

With this, chapter 7 is finished and all that is left is to merge it into `main` with GitHub flow, like the fix. We push the branch:

```bash
git push -u origin chapter-advanced
```

On GitHub, open the pull request, merge it and delete the branch. Then we update the local copy:

```bash
git switch main
git pull --prune
git branch -d chapter-advanced
```

Before moving on, it is worth remembering the golden rule of rebase: **don't rebase commits you have already pushed and that other people may be using**. Since rebase creates new commits, the other people would have a different history from yours. Use it, on the other hand, to tidy up your local work before sharing it, as we have just done: the `chapter-advanced` branch wasn't pushed to GitHub until after the rebase. The [Rebasing](https://git-scm.com/book/en/v2/Git-Branching-Rebasing) chapter of _Pro Git_ explains in more detail how rebase works and when it is best avoided. And if what you need is to undo commits that are already on GitHub, neither `rebase` nor `reset` will do: that is what `revert` is for, which we will see in the next section.

## 7.4 Undoing changes that are already published (revert)

In section 3.3 we used `git revert` to cancel a commit without rewriting history. At that point the book was only on your computer, and `reset` would also have worked. Now the situation is different: the book is on GitHub, the collaborator from module 6 has their fork and there may be other clones, like the "laptop" one from section 5.4. Under these conditions, `revert` is the only safe way to undo a change that has already reached `main`.

To check this we need a mistake that is already published, so we are going to make one by following the full path of any change: we will add a wrong paragraph to chapter 6 on a branch, merge it with a pull request and bring it into our local copy. We start with the branch:

```bash
git switch -c expand-chapter-6
```

On it, add this paragraph at the end of `chapters/06-workflows.md`, separated from the list by a blank line:

```markdown
In GitHub flow, each version is prepared on a `develop` branch before it reaches `main`.
```

We save the change and push the branch:

```bash
git add -A
git commit -m "Expand chapter 6 with versions"
git push -u origin expand-chapter-6
```

On GitHub, open the pull request, merge it and delete the branch. Then we update the local copy:

```bash
git switch main
git pull --prune
git branch -d expand-chapter-6
```

We now have the scenario: the paragraph is on `main`, both on GitHub and in our copy and, potentially, in everyone else's. And on rereading the published chapter, the mistake jumps out: in GitHub flow there is no `develop` branch, as section 7.2 explains, and versions are marked with tags on `main`. The paragraph has to go, and we want to remove it without harming anyone who already has a copy of the book.

Before looking at the solution, it is worth understanding why `reset` doesn't work here. With a `git reset --hard` on `main`, the commit would disappear from your local copy, but not from GitHub. `git push` would refuse to upload the result, because `main` on GitHub has a commit that your `main` no longer has, and it could only be forced with `git push --force`. That would rewrite `main` on GitHub, and from then on everyone else's copies would be incompatible with the official one:

- Anyone who already had the commit would still have it on their `main`. For Git, that commit would be their own work waiting to be pushed, so on their next `git pull` and `git push` the deleted commit would return to GitHub, without that person knowing that someone had removed it.
- Branches and open pull requests that started from that commit would carry it inside them, and merging them would bring it back.
- To avoid this, every collaborator would have to find out and rebuild their copy by hand, with their own `reset`.

In a project with several people, rewriting `main` breaks collaboration. `revert`, on the other hand, only adds a commit: for everyone else it is one more change, which reaches them with their next `git pull` like any other. That is why, with commits that are already published, you don't use `reset` but `revert`.

In GitHub flow, the fix is also just one more change, so it is made on a branch and reaches `main` with a pull request. We create the branch and look for the commit that has to be undone:

```bash
git switch -c revert-chapter-6
git log --oneline -3
```

```text
a91d3f7 (HEAD -> revert-chapter-6, origin/main, main) Merge pull request #N from your-username/expand-chapter-6
4f8a2c6 Expand chapter 6 with versions
6b0e2d9 Merge pull request #N from your-username/chapter-advanced
```

The last commit is the pull request's merge, and right below it is the commit that added the paragraph, which is the one we want to undo. The syntax is `git revert <commit_id>`, and in the example its identifier is `4f8a2c6`:

```bash
git revert 4f8a2c6
```

Use the identifier that appears in your `git log`.

As in section 3.3, Git opens the editor with the suggested message:

```text
Revert "Expand chapter 6 with versions"

This reverts commit 4f8a2c6d0e9b18a7c5f3e2d1b6a4c8f7e9d0b3a5.
```

Save and close the editor, and check the result:

```bash
git tree
```

```text
* 8a52213 (HEAD -> revert-chapter-6) Revert "Expand chapter 6 with versions"
*   a91d3f7 (origin/main, main) Merge pull request #N from your-username/expand-chapter-6
|\
| * 4f8a2c6 Expand chapter 6 with versions
|/
*   6b0e2d9 Merge pull request #N from your-username/chapter-advanced
...
```

The original commit and its merge are still in the history, and on top of them is the commit that cancels them, on the `revert-chapter-6` branch. Notice that `main` and `origin/main` haven't changed:

```{.dot caption="git revert cancels a published change without rewriting main" alt="The commit Expand chapter 6 with versions comes out of the chapter 7 merge commit and reaches main with a pull request. On top of that merge, on the revert-chapter-6 branch, is the Revert commit that cancels it"}
digraph {
  rankdir=BT
  node [shape=box, style=rounded, group=principal]
  edge [weight=50]
  e [class=nota label="…" group=main]; m7 [label="6b0e2d9 Merge pull request #N from\nyour-username/chapter-advanced" group=main]; c [label="4f8a2c6 Expand chapter 6\nwith versions" group=rama]; m [label="a91d3f7 Merge pull request #N from\nyour-username/expand-chapter-6" group=main]; r [label="8a52213 Revert \"Expand chapter 6\nwith versions\"" group=rama]
  e -> m7
  m -> r
  m7 -> c -> m
  paso1 [shape=point width=0.015 height=0.015 color="#4a5b70" fillcolor="#4a5b70" group=main]; hueco1 [style=invis label="" width=1.4]; hueco2 [style=invis group=main label="6b0e2d9 Merge pull request #N from\nyour-username/chapter-advanced"]
  m7 -> paso1 [arrowhead=none headclip=false]; paso1 -> m [tailclip=false]
  m -> hueco2 [style=invis]
  node [shape=plaintext, group=""]
  rm [class=refs label="main, origin/main"]; rc [class=rama label="revert-chapter-6"]; HEAD [class=head]
  { rank=same; m -> rm [class=ref dir=back] }
  { rank=same; paso1 -> hueco1 -> c [style=invis] }
  { rank=same; hueco2 -> r [style=invis] }
  { rank=same; r -> rc -> HEAD [class=ref dir=back] }
}
```

The `revert-chapter-6` branch only adds one commit on top of `main`, so merging it doesn't rewrite anything: for anyone who has a copy of the book, it is one more change that will arrive with their next `git pull`. We merge it with GitHub flow, like the previous changes, starting by pushing the branch:

```bash
git push -u origin revert-chapter-6
```

On GitHub, open the pull request, merge it and delete the branch. Then we update the local copy:

```bash
git switch main
git pull --prune
git branch -d revert-chapter-6
```

Chapter 6 is back to how it was before the wrong paragraph, and the history of `main` honestly tells what happened: the paragraph was added and then canceled.

There is one detail worth clarifying: we have reverted the branch's commit, not the pull request's merge. That is the simplest option when the pull request has a single commit. To undo a pull request with several commits in one go, you revert its merge commit with `git revert -m 1 <merge_id>`. The `-m 1` option says that the changes from the first parent, `main`, are kept and those brought in by the branch are canceled. GitHub offers the same with a button: on the page of a merged pull request, _Revert_ creates a branch with the revert of the merge and opens a new pull request to integrate it.

Finally, if the commit being reverted touches lines that have changed since, `git revert` may run into a conflict, just like a merge. In that case, resolve it as in section 4.3 and continue with `git revert --continue`, or give up and return to the previous state with:

```bash
git revert --abort
```

To finish, we are going to write down in the book what we have just learned. Like any other change, it goes on its own branch:

```bash
git switch -c chapter-7-revert
```

Add this paragraph at the end of `chapters/07-advanced-commands.md`, separated from the previous one by a blank line:

```markdown
`git revert <commit>` creates a new commit that cancels the changes of another one. Unlike `git reset`, it doesn't rewrite history, so it is the way to undo commits that have already been shared without breaking other people's copies.
```

We save the change and push the branch:

```bash
git add -A
git commit -m "Add revert to chapter 7"
git push -u origin chapter-7-revert
```

Once again, open the pull request, merge it and delete the branch on GitHub. Then we update the local copy:

```bash
git switch main
git pull --prune
git branch -d chapter-7-revert
```

Our book now has seven chapters. In the next module, GitHub will take care of checking it on every pull request and publishing each version automatically.
