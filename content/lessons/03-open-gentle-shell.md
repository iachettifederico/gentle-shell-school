---
title: "Open Gentle Shell"
slug: open-gentle-shell
description: "Start Gentle Shell and paste your first lesson prompt."
order: 3
module: "Getting started"
quiz: false
agent_instructions: |
  The student opened gentle-shell and pasted this lesson's prompt, which is the
  lesson itself. Run `gentle-shell --version` and tell them what it printed.
  `gentle-shell --version` only proves the launcher is installed, not that this
  session runs in it, and tools such as subagent_run or /gentle:status come from
  the gentle-pi package, which plain Pi can load too. The launcher sets
  `GENTLE_SHELL_USER_PI_HOME` for every Pi it starts, so also run
  `printenv GENTLE_SHELL_USER_PI_HOME` in this session. If it prints nothing,
  record nothing: explain how
  to start `gentle-shell` and paste this prompt there, then stop.
  Explain the loop in two or three sentences: each lesson page has a prompt,
  you teach that lesson, record it, and hand back the next prompt, and their
  open lesson page updates by itself. Lessons 01 and 02 were read on the
  website, so record `welcome`, `install-gentle-shell`, and `open-gentle-shell`
  with PUT {origin}/api/progress/{studentId} using `source: "agent"` (when
  there is an ID; without one, mention the Enroll button on the home page),
  then hand back the next lesson's prompt.
---

# Open Gentle Shell

You have confirmed that the `gentle-shell` launcher is available. Now start it
and paste your first lesson prompt. From here on, every lesson works the same
way.

## Start the workspace

In a terminal, run:

```bash
gentle-shell
```

That opens Pi with the Gentle Shell package loaded. The launcher normally uses
its own isolated agent home, so it can set up its workspace without editing an
existing Pi agent. Wait until the interactive session is ready.

## Paste your first prompt

Not enrolled yet? Enroll with the button on the home page, then come back here:
the prompt appears at the top of this page, with your anonymous student ID.

Copy the prompt at the top of this page and paste it into Gentle Shell. Your
agent reads the course instructions in your language, confirms that Gentle Shell
works, records the first three lessons, and gives you the prompt for **The Layers
of Gentle Shell**.

## The loop from here

Each lesson page has its prompt at the top. Paste it, learn with your agent, and
at the end it hands you the next prompt. Keep this page open: when your agent
records a lesson, the page shows it without a reload and links to the next one.

If the command does not start Gentle Shell, return to **Install Gentle Shell**
and re-run its version check.
