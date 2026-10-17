# Appendix: useful references

This appendix collects the resources cited throughout the course, grouped by topic. As explained in section 1.2, there is no need to memorize every command: it is enough to understand what it does and know where to look it up. Each resource includes its address, so that you can also copy it from the PDF or the Word file, and in parentheses the section where it is cited.

## Git

- **Official Git website (<https://git-scm.com>)**: downloads for every operating system (1.2).
- **Git cheat sheet (<https://git-scm.com/cheat-sheet>)**: the most common commands on a single page. It is the quick reference for everyday work (1.2).
- **Git documentation (<https://git-scm.com/docs>)**: the reference manual for every command and all its options, the same one shown by `git help <command>` (1.2).
- **_Pro Git_ (<https://git-scm.com/book/en/v2>)**: a complete, free book about Git. It is the reference text for digging deeper into any topic (1.2 and 7.3).
- **Oh Shit, Git!?! (<https://ohshitgit.com>)**: solutions to the most common mistakes (3.2).
- **Learn Git Branching (<https://learngitbranching.js.org>)**: interactive, visual exercises for practicing branches, merges and rebase (module 4).
- **Semantic Versioning (<https://semver.org>)**: the `MAJOR.MINOR.PATCH` format of version tags (3.4).

## GitHub

- **GitHub (<https://github.com>)**: the platform where the book is hosted (module 5).
- **GitHub documentation (<https://docs.github.com/en>)**: the reference for everything GitHub offers (1.2).
- **Connecting to GitHub with SSH (<https://docs.github.com/en/authentication/connecting-to-github-with-ssh>)**: creating keys and troubleshooting connection problems (5.1).
- **First Contributions (<https://github.com/firstcontributions/first-contributions>)**: a project designed for practicing your first pull request on a real repository (6.1).
- **Choose a License (<https://choosealicense.com>)**: help for choosing the license of an open source project (6.3).
- **github/gitignore (<https://github.com/github/gitignore>)**: `.gitignore` templates for almost any language, editor and operating system (2.5).
- **GitHub flow (<https://docs.github.com/en/get-started/using-github/github-flow>)**: the workflow the book follows from module 7 onwards (7.2).
- **A successful Git branching model (<https://nvie.com/posts/a-successful-git-branching-model/>)**: the original GitFlow article (7.2).
- **Graphical interfaces**: GitHub Desktop (<https://desktop.github.com>), GitKraken (<https://www.gitkraken.com>) and Sourcetree (<https://www.sourcetreeapp.com>) (7.1).

## Markdown

- **Markdown Guide (<https://www.markdownguide.org>)**: a complete guide to Markdown syntax, with examples (2.2 and 6.3).
- **Markdown cheat sheet (<https://www.markdownguide.org/cheat-sheet/>)**: the basic and extended syntax on a single page (2.2 and 6.3).
- **Writing on GitHub (<https://docs.github.com/en/get-started/writing-on-github>)**: the Markdown extras that GitHub adds, such as task lists and alerts (6.3).
- **markdownlint (<https://github.com/DavidAnson/markdownlint>)**: the style rules the book's CI checks (8.4).

## GitHub Actions

- **GitHub Actions documentation (<https://docs.github.com/en/actions>)**: guides and reference for workflows, events, jobs and runners (8.1).
- **Workflow syntax (<https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax>)**: every key a workflow file accepts (8.3).
- **GitHub Actions Marketplace (<https://github.com/marketplace?type=actions>)**: the catalog of actions published by GitHub and by the community (8.4).
- **crontab.guru (<https://crontab.guru>)**: checks cron expressions and translates them into plain English (8.7).
- **git-auto-commit-action (<https://github.com/stefanzweifel/git-auto-commit-action>)**: an action that lets a workflow make commits to the repository (8.6).
- **lychee (<https://github.com/lycheeverse/lychee>)**: a broken link checker (8.7).

## Tools used in the example

These tools are not part of Git or GitHub: they are only used to generate the book (see the [Appendix: example dependencies](09-appendix-example-dependencies.md)).

- **Pandoc (<https://pandoc.org>)**: converts the book from Markdown to Word, PDF and HTML (2.5).
- **Typst (<https://typst.app>)**: the engine Pandoc uses to generate the PDF (2.5).
- **Homebrew (<https://brew.sh>)**: a package manager for macOS and Linux (1.2).
- **Node.js (<https://nodejs.org>)**: needed to run markdownlint locally (8.4).
