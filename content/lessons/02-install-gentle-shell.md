---
title: "Install Gentle Shell"
slug: install-gentle-shell
description: "Install Gentle Shell with the documented path for your operating system."
order: 2
module: "Getting started"
quiz: false
agent_instructions: |
  The student read this lesson on the website to install gentle-shell, and is
  now talking to you through it. Confirm it: run `gentle-shell --version` and
  tell them what it printed. If it prints version information, record
  completion (and `welcome`, if it is not complete yet) with PUT
  {origin}/api/progress/{studentId} using `source: "agent"`, then hand back
  the next lesson's prompt. If it fails, help them through the documented
  installer path for their operating system in this lesson's content instead of
  guessing at PATH changes or package commands.
---

# Install Gentle Shell

Read this lesson here, on the website: until Gentle Shell is installed there is
no agent to paste a prompt into. The goal is narrow and observable: make the
`gentle-shell` command available, then confirm it with `gentle-shell --version`.

Start by identifying your operating system. The documented download installer is
the simplest path and needs no terminal. It installs the pieces Gentle Shell
needs, or updates an existing installation, and shows a plan before it changes
anything. Download only from the Gentle Shell repository's Releases page.

## Use the installer for your system

Choose the archive documented for your operating system:

- **macOS:** download `gentle-shell-installer-macos.zip`, open it, then
  double-click **Install Gentle Shell.command** in the *Gentle Shell Installer*
  folder.
- **Windows:** download `gentle-shell-installer-windows.zip`, right-click it and
  choose **Extract All**, then open the extracted *Gentle Shell Installer*
  folder and double-click **Install Gentle Shell.cmd**. Do not run it from inside
  the zip file.
- **Linux:** download `gentle-shell-installer-linux.tar.gz`, extract it, then
  double-click `install-gentle-shell.sh`. If your file manager opens the script
  in an editor, run this command in the extracted folder:

```bash
sh install-gentle-shell.sh
```

The installer opens a small window and then a browser page. Keep that small
window open until the browser says the installation is done. On a new bundled
installation, Gentle Shell keeps its own Node.js, npm, pnpm, and Pi under
`~/.gentle-shell`; it does not use or change your own tools.

The download installers are currently unsigned, so macOS or Windows may warn
you the first time. Follow the operating system guidance in the Gentle Shell
README linked from the release rather than bypassing an unexpected warning. If
your operating system is not macOS, Windows, or Linux, follow the README's
Get started link for a documented path; this course does not invent one.

## Confirm the command

When the installer finishes, open a new terminal if it asks you to, then run:

```bash
gentle-shell --version
```

A successful command prints Gentle Shell, Pi, and home version information.
That is the check for this lesson: it proves that your terminal can find the
launcher. If the command is not found or does not print version information,
return to the installer result and its documented guidance instead of guessing
at PATH changes or package commands.

## Other documented paths

The README also documents a standalone npm path and a path for adding the
package to an existing Pi installation. Those are useful ownership choices, but
the download installer is the path taught here because it is documented for all
three supported operating systems. Read the README's **Get started** section if
you deliberately need one of those alternatives.

## Try it

Follow the installer path for your operating system and run
`gentle-shell --version`. When it prints version information, continue with
**Open Gentle Shell**: it starts Gentle Shell and shows you where to paste your
first prompt.
