---
title: "Install, Check, Update, and Remove"
slug: install-and-update
description: "Choose an installation path and maintain it without confusing Pi and Gentle Shell updates."
order: 5
module: "Foundations"
quiz: true
agent_instructions: |
  Teach installation as an ownership choice. Contrast an isolated standalone
  Gentle Shell home, linking an existing Pi home, and installing gentle-pi into
  an existing Pi. Explain setup checks, update channels, and the difference
  between self-uninstalling Gentle Shell and Pi's package uninstall alias.

  Ask these questions with ask_user_question, including the correct answer:
  1. What home does plain `gentle-shell` use by default?
     Correct answer: Its isolated `~/.gentle-shell/agent` home.
  2. What does `gentle-shell --link` reuse?
     Correct answer: The existing Pi agent home, including its sign-ins, models,
     and chats.
  3. Which command updates Gentle Shell along its release or main channel?
     Correct answer: `gentle-shell upgrade`.
  4. Which command previews removal without deleting anything?
     Correct answer: `gentle-shell self-uninstall --dry-run`.

  Have the student run `/gentle:status` and `/gentle:doctor` in a Gentle Shell
  session, or explain why they cannot yet do so. The lesson is done when they
  can identify their installation path and distinguish `update`, `upgrade`, and
  `self-uninstall`.
---

# Install, Check, Update, and Remove

An installation is not just a way to make a command appear on `PATH`. It decides
which agent home holds state, whether your existing Pi configuration is reused,
and which tool owns future updates. Gentle Shell documents several paths because
they make different tradeoffs. Pick one deliberately before you start treating
it as your daily workspace.

## Choose the installation boundary

The standalone path installs the current package and starts the launcher:

```bash
npm i -g gentle-pi
gentle-shell
```

Plain `gentle-shell` uses an isolated agent home at
`~/.gentle-shell/agent`. Its Gentle Shell settings live separately at
`~/.gentle-shell/gentle-ai`. On first use, the launcher sets the isolated home
up; this keeps the normal Pi installation untouched and avoids conflicting
plugins in the separate home.

If you intentionally want the same Pi home instead, start with:

```bash
gentle-shell --link
```

Linked mode reuses `~/.pi/agent` as-is. It is never automatically provisioned
and its theme is not changed by the launcher. This is convenient when you want
the same sign-ins, models, and chats, but it also means the two entry points
share that home. You can make either choice the default with `gentle-shell home
link` or `gentle-shell home isolated`.

A third path is for people already using Pi and wanting the package inside that
existing Pi agent. Install the package through Pi, restart Pi, and synchronize:

```bash
pi install npm:gentle-pi
gentle-ai sync
pi
```

This is not required for the standalone launcher. Installing `npm:gentle-pi`
inside an isolated Gentle Shell home is unnecessary because the launcher already
loads its own package.

## Setup is provisioning, not a mystery repair command

`gentle-shell setup` provisions the resolved home with the companion packages
that Gentle AI installs for a Pi agent. The first launch of an isolated home
runs this provisioning automatically; the explicit command exists when you want
to run it again and see its output.

```bash
gentle-shell setup
```

Use a home selector *before* `setup` if you mean another home. For example,
`gentle-shell --link setup` targets the linked Pi home. The launcher also
supports a careful import route for a separate home:

```bash
gentle-shell home import-pi --dry-run
gentle-shell home import-pi
```

The dry run lets you inspect the plan. Import copies only the Pi sign-in file and
MCP configuration into the separate home when absent, plus default provider,
model, and thinking settings when absent. It never overwrites those files or
settings, changes the source Pi home, or copies packages, extensions, caches, or
chats. Copying credentials creates a second credential store, so providers that
rotate refresh tokens can sign one store out; linked mode instead shares one
store.

## Check the setup from the running workspace

After starting Gentle Shell, use these workspace commands:

```text
/gentle:status
/gentle:doctor
```

They are the documented starting point for checking the setup. The important
habit is to inspect the running environment rather than infer it from an old
terminal command. In particular, a successful global package installation does
not prove that a specific Pi home has the package or companions you expect.

The launcher’s own `--version` is useful for a complementary check:

```bash
gentle-shell --version
```

It reports Gentle Shell, Pi, and the selected home mode and directory.

## Update the thing you actually mean

Three similar words name different operations:

- `gentle-shell update [target]` forwards Pi's package update command for the
  selected home. Without a target in a bundled installation, it runs
  `gentle-shell upgrade` instead.
- `gentle-shell upgrade` updates **Gentle Shell** along its channel.
- Pi’s `update` command is Pi’s package-update mechanism; in a bundled install,
  Pi itself ships pinned with Gentle Shell, so the documented route for that
  update is `gentle-shell upgrade`.

On a launcher that supports it, update Gentle Shell’s current channel with:

```bash
gentle-shell upgrade
```

You can switch between the documented release and main channels:

```bash
gentle-shell upgrade --channel main
gentle-shell upgrade --channel release
```

A bundled installation follows the release channel and can keep a previous
version for rollback:

```bash
gentle-shell upgrade --rollback
```

The main channel builds Gentle AI and Gentle Shell from current main commits and
needs pnpm and Go. The release channel restores the pinned Gentle AI binary when
switching back. Do not substitute `update` for `upgrade` merely because both
sound like maintenance; they have different owners.

## Remove only what you intend to remove

First inspect the removal plan:

```bash
gentle-shell self-uninstall --dry-run
```

Then run the interactive removal only if the plan is right:

```bash
gentle-shell self-uninstall
```

Self-uninstall prints the full plan and waits for confirmation. By default it
removes Gentle Shell’s own data, isolated home, and package while keeping shared
Gentle AI configuration. `--include-shared` asks to remove those listed shared
configuration files too; `--yes` skips the first confirmation but still keeps
shared configuration unless paired with `--include-shared`.

Do not confuse this with `gentle-shell uninstall <source>`. That is forwarded to
Pi as Pi’s alias for removing a package source. It is not the command to remove
Gentle Shell itself. Self-uninstall also promises not to touch the Pi home or
custom `--home` homes.

## Common mistakes

- **Using `--link` expecting a copy.** It reuses the Pi home.
- **Running setup without considering the selected home.** The selector before
  `setup` determines the target.
- **Calling `update` when the goal is a new Gentle Shell release.** Use
  `upgrade` for the shell’s channel.
- **Deleting files manually after a failed uninstall plan.** Read the plan and
  use the explicit self-uninstall path instead.

## Try it

Run `gentle-shell --version`, then open a session and run `/gentle:status` and
`/gentle:doctor`. State whether you are isolated, linked, or using an existing
Pi installation. Finally, say which command you would use to update Gentle Shell
and which command you would use only to preview its removal.
