# Module 8: GitHub Actions (automation and CI/CD)

Until now, we have checked and generated the book by hand. In this module we are going to let GitHub take care of those tasks: it will check the syntax of the chapters on every pull request, publish a Release with the Word file and the PDF and a website with the HTML version every time we create a version tag, and check every week that the book's links still work.

## 8.1 What is GitHub Actions?

**GitHub Actions** is GitHub's automation system. It runs tasks on GitHub's machines when something happens in the repository (a push, a pull request, a new tag…) or at scheduled times. It is used above all for two practices:

- **Continuous integration** (CI): automatically checking every change before it is integrated, with tests, builds or style checks. In our book, checking the Markdown syntax.
- **Continuous deployment** (CD): automatically publishing the result when a change is ready. In our book, the Releases and the website.

It is also useful for any repetitive task, such as checking links, labeling issues or generating reports. Before writing our first workflow, it is worth knowing its pieces:

- **Workflow**: an automated process, defined in a YAML file inside the repository's `.github/workflows/` folder.
- **Event**: what triggers the workflow, such as a `push`, a pull request, a new tag or a scheduled time.
- **Job**: a set of steps that runs on a machine. A workflow can have several jobs, in parallel or chained.
- **Step**: each step of a job. It can be a terminal command (`run`) or an **action** (`uses`), a reusable block that someone has published for a common task.
- **Runner**: the virtual machine a job runs on. GitHub creates it clean for each run and destroys it at the end.

In this module we will see what is needed to automate our book. For everything else, the [GitHub Actions documentation](https://docs.github.com/en/actions) explains each piece with examples.

The diagram shows how these pieces fit together in the workflow we are going to build throughout the module:

```{.dot caption="Pieces of a GitHub Actions workflow" alt="An event, such as a push or a pull request, triggers the ci.yml workflow. The workflow has two jobs, lint and release, each on its own runner and with its list of steps. release starts when lint has finished"}
digraph {
  rankdir=TB
  compound=true
  newrank=true
  labelloc=t
  node [shape=box]
  evento [class=zona label="Event: push, pull request, tag…"]
  subgraph cluster_workflow {
    label="Workflow: .github/workflows/ci.yml"
    subgraph cluster_lint {
      label="Job lint (Ubuntu runner)"
      l1 [class=zona label="Step: download the repository"]
      l2 [class=zona label="Step: check the syntax"]
      l1 -> l2 [class=accion]
    }
    subgraph cluster_release {
      label="Job release (another Ubuntu runner)"
      r1 [class=zona label="Step: install Pandoc and Typst"]
      r2 [class=zona label="Step: generate the book"]
      r3 [class=zona label="Step: create the Release"]
      r1 -> r2 -> r3 [class=accion]
    }
  }
  evento -> l1 [class=accion lhead=cluster_workflow]
  { rank=same; l1 -> r1 [class=accion label="  then  " ltail=cluster_lint lhead=cluster_release] }
}
```

GitHub offers runners with Ubuntu (`ubuntu-latest`), Windows (`windows-latest`) and macOS (`macos-latest`), and each job chooses its own. Linux is the fastest and the one used almost always, while Windows and macOS are for testing programs on those systems. In public repositories, standard runners are free with no limit on minutes. In private ones, on the other hand, each account has a number of free minutes per month, and Windows and macOS runners use up those minutes faster than Linux ones.

## 8.2 Creating the first workflow

Like any change to the book, the CI is prepared on a branch, following GitHub flow. We start from the latest version of `main` and create the branch:

```bash
cd ~/projects/git-handbook
git switch main
git pull
git switch -c ci
```

Workflows are stored in the repository's `.github/workflows/` folder, one YAML file per workflow. GitHub runs all the ones it finds in that folder, and the file name is up to you. We create the first one:

```bash
mkdir -p .github/workflows
code .github/workflows/ci.yml
```

To start with, this first workflow will only check the syntax of the Markdown files. Write this content:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  lint:
    name: Check the Markdown syntax
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: DavidAnson/markdownlint-cli2-action@v24
        with:
          globs: "**/*.md"
```

In the next two sections we will see what each line means, so don't commit yet.

## 8.3 Structure and basic syntax of a workflow

YAML is a text format for structured data, designed to be written by people. To read and write workflows, three rules are enough:

- Each `key: value` line defines a piece of data. The value can be text, a number or a block of more indented lines.
- Indentation shows what goes inside what. It is always done with spaces, never with tabs, and all the lines at the same level must have the same indentation.
- Lines starting with `-` are items in a list. `[main]` is the same list written on a single line, and `#` starts a comment.

With that we can already read our workflow. Its main keys are:

- `name`: the name of the workflow, the one that appears in GitHub's _Actions_ tab.
- `on`: the events that trigger it. Here, a `push` to `main` (which is what happens when a pull request is merged) and any pull request, every time it is opened or updated.
- `jobs`: the workflow's jobs. `lint` is the job's identifier, the one used to refer to it from other jobs, and `name` its visible name.
- `runs-on`: the runner the job runs on.
- `steps`: the list of steps, which run in order. If one fails, the following ones don't run and the job ends with an error.

There is no need to remember every possible key: the [workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax) page in the GitHub documentation describes them all.

## 8.4 Using GitHub and community actions (Marketplace)

Both steps of the job use `uses`, which runs an action. An action is a reusable block published in a GitHub repository, and it is written in the form `owner/repository@version`. There are thousands in the [Marketplace](https://github.com/marketplace?type=actions), for almost any task, so before using one it is worth checking who publishes it (GitHub's are in the `actions` organization, and those from verified companies carry a badge), that it is maintained and that it has good documentation. These are the two we use:

- `actions/checkout@v7`, published by GitHub, downloads the repository onto the runner. Since the runner starts empty, almost every workflow begins with this step.
- `DavidAnson/markdownlint-cli2-action@v24`, published by the author of markdownlint, runs [markdownlint](https://github.com/DavidAnson/markdownlint), a tool that checks that Markdown files follow a set of style rules.

`with` passes parameters to the action, and each action documents its own on its repository page. In our case, `globs` says which files to check: every `.md` in the repository, in any folder.

The version after `@` is a tag in the action's repository. A tag like `@v7` automatically follows the latest 7.x version, which receives fixes without incompatible changes, and is what the official documentation recommends. In projects with strict security requirements, the full commit identifier of the action (`@<sha>`) is pinned instead, so that nobody can change what runs.

What is left is to tell markdownlint which rules to apply. They are configured in a `.markdownlint.jsonc` file at the root of the repository, which we will create with this content:

```jsonc
{
  // Paragraphs on a single line, with no length limit
  "MD013": false,
  // Italics with _
  "MD049": { "style": "underscore" },
  // Bullets with -
  "MD004": { "style": "dash" }
}
```

By default, markdownlint applies about 50 rules (headings surrounded by blank lines, code blocks with a language, a single level 1 heading, etc.). This file turns off the line length limit and sets the italics and bullet style of our book. If you have [Node.js](https://nodejs.org) installed, you can run the same check locally with `npx markdownlint-cli2 "**/*.md"`.

With both files ready, we save them and push the branch:

```bash
git add -A
git commit -m "Add the CI with the syntax check"
git push -u origin ci
```

Now open the pull request on GitHub, as in section 7.2. This time you will notice something new: at the bottom of the page, next to the _Merge pull request_ button, there is a section of _checks_ with _CI / Check the Markdown syntax_, which shows a yellow circle while it runs and a green check mark when it finishes. The pull request's _Checks_ tab shows the details. This is the great advantage of CI in a pull request: before merging, anyone can see whether the change meets the project's rules.

Merge the pull request and delete the branch on GitHub. Then we update the local copy:

```bash
git switch main
git pull --prune
git branch -d ci
```

When you merge, the push to `main` triggers the workflow again, so in the repository's _Actions_ tab you will see two runs: the pull request one and the `main` one.

## 8.5 Running scripts and commands on the virtual machine

With the automatic check up and running, the next step is to publish each version of the book without manual intervention. What we want is that, when we push a tag such as `v1.1.0`, GitHub generates the Word file and the PDF and attaches them to a Release. As always, we prepare the change on a new branch:

```bash
git switch -c publishing
```

Open `.github/workflows/ci.yml`. First you have to add version tags to the events, so that the workflow also runs when a tag starting with `v` is pushed:

```yaml
on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:
```

Next, add a second job, `release`, at the end, at the same level as `lint`:

```yaml
  release:
    name: Generate and publish the release
    if: startsWith(github.ref, 'refs/tags/v')
    needs: lint
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v7
      - uses: pandoc/actions/setup@v1
      - uses: typst-community/setup-typst@v5
      - name: Generate the book
        run: bash build.sh "$GITHUB_REF_NAME"
      - name: Create the release
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh release create "$GITHUB_REF_NAME" dist/*.docx dist/*.pdf --title "Git Handbook $GITHUB_REF_NAME" --generate-notes
```

Unlike `lint`, this job uses `run`, which runs commands in the runner's terminal (bash, on Ubuntu), just like on your computer. Let's see what each step does:

- The first three prepare the machine: they download the repository and install Pandoc and Typst with their official actions. It is the same as what is done by hand in the dependencies appendix, but automatically.
- `Generate the book` runs the same `build.sh` from section 2.5, and `name` gives that step a readable name in the logs. It is launched with `bash build.sh` instead of `./build.sh` so as not to depend on the execute permission, which is lost if someone edits the script from Windows.
- `Create the release` uses `gh`, GitHub's official CLI, which comes installed on the runners. It creates a Release with the tag's name and attaches the `.docx` and the `.pdf` to it, while `--generate-notes` automatically writes the notes with the changes and pull requests since the previous version.

To do their job, the commands use information from the event:

- `$GITHUB_REF_NAME` is an environment variable that GitHub defines on every runner. When the event is a tag, it contains its name (for example, `v1.1.0`), so the files will be called `git-handbook-v1.1.0.docx` and `git-handbook-v1.1.0.pdf`.
- `${{ github.token }}` is an _expression_, that is, something GitHub replaces with its value before running the step. In this case, a temporary token that lets `gh` act on the repository. `env` passes it to the step as an environment variable, which is where `gh` looks for it.

Finally, the two new keys at the start of the job control when it runs:

- `if` sets a condition: the job only runs if the event is a tag starting with `v`. On a push to `main` or on a pull request, it appears as _skipped_.
- `needs: lint` chains the jobs: `release` waits for `lint` to finish successfully. That way, a book with syntax errors is never published. Without `needs`, both jobs would run at the same time.

That leaves the `permissions` block, which we will look at in the next section together with the workflow's last job.

## 8.6 Setting permissions and publishing on GitHub Pages

Each run receives a temporary token, the same one as `${{ github.token }}`, with which the workflow acts on the repository. `permissions` limits what that token can do, and it is good security practice to give it only what is essential: if an action misbehaved, it couldn't do more damage than its permissions allow. Permissions can be defined for the whole workflow and extended in each job. We start with the global read-only permission, which goes below `on`, before `jobs`:

```yaml
permissions:
  contents: read
```

The `release` job extends that permission with `contents: write`, because it needs to create the Release.

The last job will publish the HTML version of the book on **GitHub Pages**, GitHub's free web hosting service. Pages serves static sites (HTML, CSS, JavaScript and images, with no database or server code) at an address like `https://<username>.github.io/<repository>/`. The content can come directly from a branch of the repository or, as in our case, from a workflow that generates the files and deploys them. It is widely used for documentation, blogs and project pages.

Publishing has two parts. First, add a step at the end of the `release` steps that packages the `dist` folder, where `build.sh` leaves `index.html`, as the website to publish:

```yaml
      - uses: actions/upload-pages-artifact@v5
        with:
          path: dist
```

And then add the `pages` job, which handles the deployment, at the end of the file:

```yaml
  pages:
    name: Publish the website on GitHub Pages
    needs: release
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    concurrency:
      group: pages
      cancel-in-progress: false
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v5
```

This job waits for `release` and deploys to GitHub Pages the package it has just uploaded. It has three details worth understanding:

- It needs the permissions `pages: write`, to publish, and `id-token: write`, with which Pages checks that the deployment comes from this workflow.
- It runs in the `github-pages` _environment_, which GitHub creates when Pages is enabled. The `url` line makes the website's address appear in the run summary: `steps.deployment.outputs.page_url` is a value returned by the step with `id: deployment`.
- `concurrency` prevents two Pages deployments from happening at once: if two tags are published in a row, the second deployment waits in the queue and the one in progress isn't canceled.

`release` and `pages` are in two separate jobs because they are two different tasks: publishing downloadable files (the Release) and deploying a website (Pages). The diagram shows how the three jobs are chained depending on the event:

```{.dot caption="Jobs of the CI workflow depending on the event" alt="A push to main or a pull request only runs lint, and release and pages are skipped. A v tag runs lint, then release and then pages"}
digraph {
  rankdir=LR
  node [shape=box]
  cambio [class=zona label="Push to main\nor pull request"]
  etiqueta [class=zona label="Tag v*\n(for example, v1.1.0)"]
  lint1 [class=zona label="lint"]
  omitidos [class=nota label="release and pages\nare skipped (if)"]
  lint2 [class=zona label="lint"]
  release [class=zona label="release:\nWord, PDF and Release"]
  pages [class=zona label="pages:\nwebsite on GitHub Pages"]
  cambio -> lint1 [class=accion]
  lint1 -> omitidos [class=accion style=dashed]
  etiqueta -> lint2 [class=accion]
  lint2 -> release [class=accion label="  needs  "]
  release -> pages [class=accion label="  needs  "]
}
```

With all the pieces in place, the complete file looks like this:

```yaml
name: CI

on:
  push:
    branches: [main]
    tags: ["v*"]
  pull_request:

permissions:
  contents: read

jobs:
  lint:
    name: Check the Markdown syntax
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: DavidAnson/markdownlint-cli2-action@v24
        with:
          globs: "**/*.md"

  release:
    name: Generate and publish the release
    if: startsWith(github.ref, 'refs/tags/v')
    needs: lint
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v7
      - uses: pandoc/actions/setup@v1
      - uses: typst-community/setup-typst@v5
      - name: Generate the book
        run: bash build.sh "$GITHUB_REF_NAME"
      - name: Create the release
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh release create "$GITHUB_REF_NAME" dist/*.docx dist/*.pdf --title "Git Handbook $GITHUB_REF_NAME" --generate-notes
      - uses: actions/upload-pages-artifact@v5
        with:
          path: dist

  pages:
    name: Publish the website on GitHub Pages
    needs: release
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    concurrency:
      group: pages
      cancel-in-progress: false
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v5
```

We save it and integrate it with GitHub flow:

```bash
git add -A
git commit -m "Publish each version as a Release and on GitHub Pages"
git push -u origin publishing
```

Open the pull request. In the checks you will see that `lint` passes and that `release` and `pages` appear as skipped, just as we expected, because the event is a pull request and not a tag. Merge it and delete the branch on GitHub. Then we update the local copy:

```bash
git switch main
git pull --prune
git branch -d publishing
```

Before publishing the first version, Pages has to be enabled in the repository. On GitHub, go to _Settings_ → _Pages_ and, under _Build and deployment_ → _Source_, choose **GitHub Actions**.

There is also a detail that tends to catch people by surprise. When Pages is enabled, GitHub creates the `github-pages` environment with a protection rule that only allows deployments from the default branch, but our workflow deploys from tags, so they have to be allowed. To do so, go to _Settings_ → _Environments_ → _github-pages_ and, under _Deployment branches and tags_, press _Add deployment branch or tag rule_, choose _Ref type: Tag_, enter the pattern `v*` and save. Without this rule, the Pages job would fail with a message saying that the tag is not allowed to deploy to `github-pages`.

By the way, write permissions also let a workflow make commits to the repository, for example to regenerate a statistics file and push it. This is done with `contents: write` and an action such as [`stefanzweifel/git-auto-commit-action`](https://github.com/stefanzweifel/git-auto-commit-action), which commits and pushes whatever changes the job has left. Commits made with the workflow's token don't trigger other workflows, which prevents a workflow that makes commits from triggering itself endlessly. Our book doesn't need automatic commits, but the technique is worth knowing.

## 8.7 Scheduling recurring tasks (cron)

Some tasks don't depend on changes to the repository. The book's links to external pages, for example, can stop working without anyone touching the book, simply because the other website changes or disappears. To detect it we need a workflow that runs on its own, every so often, and lets us know if it finds broken links. We prepare it on a branch:

```bash
git switch -c links
code .github/workflows/links.yml
```

And give it this content:

```yaml
name: Links

on:
  schedule:
    # Every Monday at 06:00 (UTC)
    - cron: "0 6 * * 1"
  workflow_dispatch:

permissions:
  contents: read
  issues: write

jobs:
  links:
    name: Check the links
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - name: Check the links
        id: lychee
        uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress "./**/*.md"
          fail: false
      - name: Open an issue if there are broken links
        if: steps.lychee.outputs.exit_code != 0
        env:
          GH_TOKEN: ${{ github.token }}
        run: gh issue create --title "Broken links" --body-file lychee/out.md
```

What is new is the `schedule` event, which runs the workflow at the times given by a **cron** expression, made up of five fields separated by spaces:

| Field | Values | In `0 6 * * 1` |
| --- | --- | --- |
| Minute | 0-59 | 0 |
| Hour | 0-23 | 6 |
| Day of the month | 1-31 | any (`*`) |
| Month | 1-12 | any (`*`) |
| Day of the week | 0-6 (0 is Sunday) | 1 (Monday) |

So `0 0 * * *` would be every day at midnight and `*/15 * * * *`, every 15 minutes. To check an expression before using it, type it into [crontab.guru](https://crontab.guru/), which translates it into plain English. There are also several peculiarities of `schedule` to keep in mind:

- Times are always UTC, not local time.
- Only the workflow on the default branch (`main`) runs.
- At times of heavy load, the run may be delayed by a few minutes.
- In public repositories, GitHub disables scheduled workflows if the repository goes 60 days without activity.

The second event, `workflow_dispatch`, lets you launch the workflow by hand with a button on the website, without waiting for Monday, which is very useful for testing it.

As for the job, its three steps work as a chain:

- [lychee](https://github.com/lycheeverse/lychee), a link checker, checks all the Markdown files and writes a report to `lychee/out.md`. `fail: false` prevents the job from ending with an error when it finds broken links, because the goal is to warn, not to turn the repository red.
- `id: lychee` gives the step a name, and with it the next step can read its results (_outputs_). `steps.lychee.outputs.exit_code` is lychee's exit code, which is other than 0 if it has found broken links.
- Only in that case does `gh issue create` open an issue with the report as its description. That is why the workflow asks for the `issues: write` permission.

The diagram sums up the journey:

```{.dot caption="Weekly link checking workflow" alt="Every Monday at 6:00 UTC, or when Run workflow is pressed, lychee checks the links. If there are broken links, an issue is opened with the report; if not, the workflow ends without doing anything else"}
digraph {
  rankdir=LR
  node [shape=box]
  lunes [class=zona label="Every Monday\n06:00 UTC"]
  boton [class=zona label="Run workflow\nbutton"]
  lychee [class=zona label="lychee checks\nthe links"]
  pregunta [class=zona label="Broken links?"]
  issue [class=zona label="Open an issue\nwith the report"]
  fin [class=nota label="End without\ndoing anything else"]
  lunes -> lychee [class=accion]
  boton -> lychee [class=accion]
  lychee -> pregunta [class=accion]
  pregunta -> issue [class=accion label="  yes  "]
  pregunta -> fin [class=accion label="  no  "]
}
```

As long as the links aren't fixed, a new issue will be opened every Monday. When you fix them, close the issue from its page or from the pull request with the fix, by writing `Closes #<number>` in its description.

As always, we integrate it with GitHub flow:

```bash
git add -A
git commit -m "Check the links every week"
git push -u origin links
```

Open the pull request, merge it and delete the branch. Then we update the local copy:

```bash
git switch main
git pull --prune
git branch -d links
```

## 8.8 Monitoring and debugging workflows

The repository's _Actions_ tab gathers all the runs. On the left are the workflows (_CI_ and _Links_) and, in the middle, the list of runs with their status: a yellow circle if it is in progress, a green check mark if it finished successfully and a red cross if it failed. When you open a run you see its jobs, joined by arrows according to `needs`, and when you open a job, the _log_ of each step, with the same output you would see in the runner's terminal.

A good first exercise is to test the links workflow without waiting for Monday. In _Actions_, choose _Links_ on the left and press _Run workflow_ → _Run workflow_. When it finishes, open the job and expand the _Check the links_ step: the log lists each link checked and its result. If any were broken, you would also see the new issue in the _Issues_ tab.

The most interesting thing, however, is to see what happens when something fails. To do so, we are going to introduce a deliberate mistake on a test branch: a bullet with an asterisk at the end of `chapters/05-github.md`, which breaks rule MD004. We start with the branch:

```bash
git switch -c test-ci
```

Add this bullet at the end of chapter 5:

```markdown
* A bullet with the wrong style.
```

And push it as if it were a normal change:

```bash
git add -A
git commit -m "Add a bullet to chapter 5"
git push -u origin test-ci
```

We now have the scenario: a pull request with a mistake that the CI should catch. Open the pull request and you will see that this time the check ends with a red cross, that the pull request warns that there are failing checks and that GitHub sends you an email. What we want now is to find out what has failed. Press _Details_ next to the check (or open the pull request's _Checks_ tab) and expand the markdownlint step: the log shows the file, the line and the rule broken (`MD004/ul-style`). With that information, whoever sent the change knows exactly what to fix before it is merged.

Besides reading the log, from the run's page you can:

- Press _Re-run jobs_ to repeat the run, either all of it (_Re-run all jobs_) or only the jobs that failed (_Re-run failed jobs_). This is useful when the failure is a one-off (a server that wasn't responding, for example) and not due to the code.
- Turn on _Enable debug logging_ when re-running it, so that the log shows more detail.

Since the bullet was only a test, close the pull request without merging it (_Close pull request_) and delete the branch on GitHub. Then we also delete the local branch, this time with `-D`, because its changes haven't been merged:

```bash
git switch main
git pull --prune
git branch -D test-ci
```

In projects with several people, it is a good idea to prevent a pull request from being merged with a red check. This is configured in _Settings_ → _Rules_ → _Rulesets_ → _New ruleset_ → _New branch ruleset_: it applies to the default branch (`main`) and turns on the _Require status checks to pass before merging_ rule with the CI check.

## 8.9 Publishing a version

The time has come to check that everything works from start to finish by publishing version 1.1.0, which includes chapter 7 and the automation. We will also take the opportunity to make `README.md` show a _badge_ with the CI status. We prepare the version on a branch:

```bash
git switch -c version-1.1.0
```

In `metadata.yaml`, change the `date` line to `Version 1.1.0` and add this line below the title of `README.md`, separated from the title by a blank line (replace `<username>` with your GitHub username):

```markdown
![CI](https://github.com/<username>/git-handbook/actions/workflows/ci.yml/badge.svg)
```

We save the changes and push the branch:

```bash
git add -A
git commit -m "Prepare version 1.1.0"
git push -u origin version-1.1.0
```

Open the pull request, merge it when the check is green and delete the branch. Then we update the local copy, create the version tag on `main` and push it, which is what will set publishing in motion:

```bash
git switch main
git pull --prune
git branch -d version-1.1.0
git tag -a v1.1.0 -m "Version 1.1.0"
git push origin v1.1.0
```

Go back to the _Actions_ tab. You will see a _CI_ run for the `v1.1.0` tag with the three jobs chained: _Check the Markdown syntax_, _Generate and publish the release_ and _Publish the website on GitHub Pages_. When they finish, you can check the result in three places:

- On the repository's front page, in the right-hand sidebar, the _Releases_ section appears with _Git Handbook v1.1.0_. If you open it, you will see that `git-handbook-v1.1.0.docx` and `git-handbook-v1.1.0.pdf` are attached, ready to download, along with some automatically generated notes with the changes.
- In the Pages job (or in _Settings_ → _Pages_) the website's address appears: `https://<username>.github.io/git-handbook/`. Open it and you will see the whole book in HTML, with its table of contents.
- The README badge shows _passing_ in green.

The `v1.0.0` tag didn't generate any Release because it was pushed before the workflow was created. From now on, on the other hand, every version tag you push to GitHub will automatically generate its Release and update the website.

With this we have gone through the whole cycle together: writing locally with Git, collaborating on GitHub, organizing the work with a branching workflow and publishing automatically. The Git Handbook you have written sums up everything you have learned, and anyone can download it, read it on the web or suggest improvements to you. When you need to remember a command or dig deeper into a topic, the [Appendix: useful references](10-appendix-useful-references.md) collects all the resources cited in the course.
