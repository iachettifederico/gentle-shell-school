---
title: "The Layers of Gentle Shell"
slug: layers
description: "Distinguish Pi, gentle-shell, gentle-pi, Gentle AI, and optional companions."
order: 2
module: "Foundations"
quiz: true
agent_instructions: |
  Teach the product layers as separate responsibilities: Pi is the agent runtime,
  gentle-shell is the workspace experience, gentle-pi is the package that
  integrates it with Pi, and Gentle AI supplies companion workflow tooling.
  Explain that optional packages such as gentle-engram are not hidden
  prerequisites.

  Ask these questions with ask_user_question, including the correct answer:
  1. What component runs the model, tools, context assembly, and sessions?
     Correct answer: Pi.
  2. What is gentle-pi?
     Correct answer: The package that integrates the Gentle Shell workspace into
     a Pi session.
  3. Is persistent memory bundled with gentle-pi?
     Correct answer: No; gentle-engram is an optional companion.
  4. What does the gentle-shell launcher do differently from installing a
     package into an existing Pi home?
     Correct answer: It opens Pi with the package loaded without installing it
     into the Pi agent or editing that agent's settings.json.

  Ask the student to run `gentle-shell --version` and explain the Pi version it
  reports. The lesson is done when they can name the layer responsible for a
  model request, the terminal workspace, and optional persistent memory.
---

# The Layers of Gentle Shell

It is easy to call every part of an agent setup “the agent.” That shortcut makes
troubleshooting harder: a question about saved sessions, a question about a
workspace panel, and a question about memory belong to different components.
Gentle Shell is deliberately built in layers. Knowing the boundary of each one
helps you choose the right command, understand what a setup changes, and avoid
expecting an optional capability to be universal.

## Start with Pi

**Pi** is the terminal AI agent runtime. It coordinates model requests, tool
execution, context assembly, and session storage. You run it from a working
folder; that folder is the basis for discovering project resources and grouping
saved sessions. The model does not directly operate your terminal. Pi builds a
request from the system prompt, active conversation branch, tools, and model
settings, then sends it to the selected provider. When a response asks for a
tool, Pi executes the call and records its result.

Pi also provides the baseline interactive experience: the conversation
transcript, editor, footer, slash-command menu, model selector, saved sessions,
and configurable keybindings. Its tools run with the operating-system
permissions of the Pi process. Project trust governs whether project resources
are loaded; it is not a sandbox for tool calls.

That separation matters. If a plain `pi` session can choose a model, call a
built-in tool, and save a session, those are Pi capabilities—not features that
require Gentle Shell.

## Gentle Shell is the workspace

**gentle-shell** is the coding-agent workspace built for Pi. It is not merely a
terminal theme. Its workspace gives a Pi session additional ways to observe and
lead work: a shell bar, current Git changes, provider usage when Pi exposes it,
and views for native agent orchestration.

For example, Gentle Changes can show the Git working tree against `HEAD`,
including untracked files, for the session repository and relevant subagent
worktrees. Gentle Agents gives parallel work a visible card and an overlay rather
than hiding it in terminal scrollback. These views observe the work; they do not
replace Git, Pi sessions, or the need to inspect a change.

The `gentle-shell` command is also a launcher. In its standalone form it starts
Pi with the Gentle Shell package loaded, without installing the package into your
existing Pi agent or editing that agent's `settings.json`. The default isolated
home is `~/.gentle-shell/agent`; `gentle-shell --link` instead reuses the normal
Pi agent home. Those are deliberately different choices: isolation separates the
agent home, while linking reuses existing Pi sign-ins, models, and chats.

## gentle-pi is the integration package

The npm package is currently named **gentle-pi**, even though the product is
called Gentle Shell. It is the package that integrates the shell bar, workspace
changes, provider usage where Pi makes it available, and native agent views into
a Pi session. This naming distinction explains commands such as:

```bash
npm i -g gentle-pi
gentle-shell
```

The first command installs the package globally; the second launches the
workspace. Alternatively, an existing Pi installation can install the package
and then run Pi with it. These are installation paths, not competing agent
loops: Pi remains the runtime in either case.

## Gentle AI and companions

**Gentle AI** is related workflow tooling, not another name for Pi. Gentle Shell
can use it to provision companion packages and managed assets for a home. The
`gentle-ai` command has its own commands such as `install`, `sync`, `doctor`,
and `skill-registry refresh`. A regular Pi session does not become a Gentle
Shell workspace simply because the Gentle AI command exists on the machine.

Some capabilities are deliberately optional companions. `gentle-engram` provides
persistent memory; `pi-web-access`, `pi-lens`, and `pi-intercom` are also listed
as optional companions. In particular, persistent memory is **not** bundled with
`gentle-pi`. A lesson about memory later in this course covers its workflow. For
now, the safe mental model is: do not assume an extension is present merely
because another installation has it.

## Why the boundaries save time

When something goes wrong, locate the layer first:

- A model cannot authenticate or a session will not resume: start with Pi.
- You want to inspect a live diff or delegated task in the workspace: use Gentle
  Shell’s views.
- You are choosing isolated versus linked agent state: use the `gentle-shell`
  launcher behavior.
- You need an ecosystem setup or synchronization action: look at Gentle AI.
- You need durable cross-session memory: verify that the optional memory
  companion is installed and available.

This also keeps configuration claims modest. A package loaded in one agent home
need not be loaded in another. A companion is not an entitlement. And a polished
workspace does not make tool execution sandboxed.

## Common mistakes

- **Calling gentle-shell a replacement for Pi.** It is built for and runs with
  Pi; Pi supplies the agent loop and session mechanisms.
- **Treating `gentle-pi` and `gentle-shell` as unrelated products.** The former
  is the current package name; the latter is the user-facing workspace and
  launcher.
- **Assuming all installations have memory.** Persistent memory is optional.
- **Confusing a linked home with a copy.** `--link` reuses the Pi home; it does
  not create a separate credential store.

## Try it

Run `gentle-shell --version`. Then describe the result in one sentence each:
which layer will make the next model request, which layer supplies the workspace,
and which capability you would need to verify before relying on persistent
memory. That vocabulary will make the following setup lessons much clearer.
