---
title: "Check, Update, and Remove Gentle Shell"
slug: install-and-update
description: "Check your setup, choose an update channel, and remove Gentle Shell deliberately."
order: 5
module: "Foundations"
quiz: true
agent_instructions: |
  Installation is taught in the earlier Install Gentle Shell lesson. Teach this
  lesson as maintenance: checking a running workspace, updating along a
  channel, and previewing removal. Explain the difference between `update` and
  `upgrade` without treating them as synonyms.

  Ask these questions with ask_user_question, including the correct answer:
  1. Which workspace commands are the documented starting point for checking
     a running Gentle Shell setup?
     Correct answer: `/gentle:status` and `/gentle:doctor`.
  2. Which command updates Gentle Shell along its release or main channel?
     Correct answer: `gentle-shell upgrade`.
  3. Which command previews removal without deleting anything?
     Correct answer: `gentle-shell self-uninstall --dry-run`.

  Have the student run `gentle-shell --version`, then `/gentle:status` and
  `/gentle:doctor` in a Gentle Shell session. The lesson is done when they can
  identify the setup checks, say when to use `upgrade` rather than `update`,
  and name the command that previews removal.
---

# Check, Update, and Remove Gentle Shell

Installation belongs in **Install Gentle Shell**. Once Gentle Shell is running,
the useful questions change: what version and home are active, how do you check
the running workspace, which update do you mean, and how can you remove it
without deleting the wrong thing?

## Check the launcher and workspace

Start with the launcher's version report:

```bash
gentle-shell --version
```

It reports Gentle Shell, Pi, and home version information. Then, from an open
Gentle Shell session, use the documented workspace checks:

```text
/gentle:status
/gentle:doctor
```

These checks inspect the running environment. That matters because a command
that exists in one terminal does not by itself prove that a particular agent
home has the expected workspace and companion setup.

## Update the thing you mean

`gentle-shell upgrade` updates Gentle Shell along its current channel:

```bash
gentle-shell upgrade
```

On launchers that support channels, you can choose the documented release or
main channel:

```bash
gentle-shell upgrade --channel main
gentle-shell upgrade --channel release
```

The main channel builds Gentle Shell and Gentle AI from current main commits and
needs pnpm and Go. Switching back to release restores the pinned Gentle AI
binary. A bundled installation follows the release channel and keeps a previous
version that can be selected with:

```bash
gentle-shell upgrade --rollback
```

Do not confuse `upgrade` with `gentle-shell update [target]`. The latter forwards
Pi's package-update command for the selected home. In a bundled installation,
Pi is pinned with Gentle Shell, so an update of Pi itself runs `gentle-shell
upgrade` instead. Older launchers that do not support `upgrade` should use the
latest installer described in **Install Gentle Shell** rather than treating
`upgrade` as a chat prompt.

## Remove only what you intend

Always inspect the removal plan first:

```bash
gentle-shell self-uninstall --dry-run
```

If the plan is correct, the interactive command is:

```bash
gentle-shell self-uninstall
```

Self-uninstall removes Gentle Shell's own data, isolated home, and `gentle-pi`
package after confirmation. It keeps the shared Gentle AI configuration in
`~/.pi/gentle-ai` unless you accept or pass `--include-shared`, and it does not
touch your Pi home or custom `--home` homes. `gentle-shell uninstall <source>`
is different: it is Pi's alias for removing a package source, not the command
for removing Gentle Shell itself.

## Try it

Run `gentle-shell --version`, then `/gentle:status` and `/gentle:doctor` in a
Gentle Shell session. State which command updates Gentle Shell, which one updates
Pi packages, and which command previews a removal plan.
