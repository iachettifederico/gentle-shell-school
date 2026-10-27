---
title: "Permission modes"
slug: permission-modes
description: "Choose Normal, Auto, or YOLO without confusing convenience for a security boundary."
order: 22
module: "Safety and review"
quiz: true
agent_instructions: |
  Teach the student how Normal, Auto, and YOLO differ, what each mode does
  and does not authorize, and why permissions are not a sandbox. Emphasize
  that current-session mode and the default for future sessions are separate.

  Ask these questions with ask_user_question, checking each answer:
  1. Which mode uses a separate check with the current session model before eligible actions? Correct answer: Auto.
  2. Does enabling YOLO waive destructive-operation confirmations? Correct answer: No; destructive and independent consent boundaries remain.
  3. What command changes the current session to Auto? Correct answer: /gentle:mode auto.
  4. Why is Auto not a security sandbox? Correct answer: it can misjudge actions and cannot comprehensively inspect scripts, dependencies, tools, or prompt injection.

  Have the student run /gentle:mode status in their live primary session and
  explain the displayed current mode and saved default. Do not ask them to
  enable Auto or YOLO; that is their decision. The lesson is done when they
  can choose an appropriate mode for a scoped task, name one boundary that
  still needs human consent, and have checked their actual status.
---

Permission prompts are a coordination problem: a coding agent can make many
small actions while you still need meaningful control over the consequential
ones. Gentle Shell offers three ways to handle those questions in the current
**primary** session: **Normal**, **Auto**, and **YOLO**. They are not three
security levels and none is an operating-system sandbox. Pi processes, tools,
and extensions still act with the permissions of the account that started Pi.
Isolation, limited credentials, and limited network access remain the controls
that contain a bad or hostile action.

This lesson is about the permission decision path. It follows the boundary set
up in **Authorize and explore**: changing a mode does not enlarge the task you
authorized, make a remote destination known, or decide an unresolved product
choice.

## The three modes

**Normal** preserves the existing permission behavior and is the fallback when
there is no valid saved global preference. Use it when you want to make
individual decisions in the normal interaction flow.

**Auto** places an independent check in front of eligible primary tool calls.
That check uses the current session model and compares the proposed action with
your live request and restrictions. It does not make the acting conversation
approve itself. Auto covers local reads as well as writes, shell tools, custom
and MCP tools, and nested calls that go through Pi's tool-event pipeline.
Locality is not an exemption: if you said not to read a file, a local read is
still subject to that restriction.

Auto has a cost. The independent inference adds latency and, depending on the
provider, token cost. It is deliberately bounded: ordinary checks are
tool-free; an eligible script check can inspect only host-selected project
files, at most two complete files of up to 8 KiB each, across at most three
provider calls. Inspection is evidence gathering, never authorization. A
missing, stale, invalid, cancelled, timed-out, or unavailable verdict does not
run the action. Narrow the proposed action, wait and retry, or make a manual
permission decision; do not try to disguise the same effect through another
tool or a delegate.

**YOLO** supplies standing permission for ordinary work that is already in
scope: implementation, checks, ordinary commits, non-force pushes, and pull
request creation. It avoids repeated routine prompts during a long,
autonomous-but-scoped run. YOLO has no Auto classifier.

The important word is *scoped*. YOLO does not authorize a new account,
credential, remote destination, deployment destination, privacy-sensitive
disclosure, or a consequential decision that the task leaves open. It also does
not give delegated children its elevated permission or independent delivery
permission.

## Change the live mode deliberately

Use the mode commands in an interactive primary session:

```text
/gentle:mode status
/gentle:mode auto
/gentle:mode normal
/gentle:mode yolo
```

The first command is a useful no-change check: it shows the current mode and
the saved default. The mode-selection commands affect exactly the current
interactive primary session. You can also use the older YOLO shortcut:

```text
/gentle:yolo enable
/gentle:yolo disable
/gentle:yolo status
```

`enable` selects YOLO for the live session; `disable` selects Normal. With no
argument, `/gentle:yolo` opens its interactive menu when that UI is available,
or reports status otherwise. Invalid arguments change nothing.

The Customize interface exposes the same distinction. In
`/gentle:customize` → **Editor**, **Session permissions** changes the current
mode, while **Default permissions** saves a preference for future sessions.
The YOLO row is explicitly session-only. Browsing, previewing, closing a menu,
or pressing Escape never grants permission.

To save a default for a *new* primary session, use a separate command:

```text
/gentle:mode default auto
/gentle:mode default yolo
/gentle:mode default normal
```

This is a common source of mistakes: `/gentle:mode default auto` does not
change the current session, and `/gentle:mode normal` does not erase a saved
future-session default. To put both this session and future sessions back to
Normal, run both `/gentle:mode normal` and `/gentle:mode default normal`.
Current-session selection takes precedence over the global default. Repository
settings and visual profiles cannot supply that default.

Live permissions are tied to the session and workspace or clone identity.
Reload, shutdown, or session replacement revokes the live selection and pending
actions. A newly initialized session can apply a saved default, but that is a
new application of a global preference, not restoration of an old transcript
grant.

## The boundaries that remain

Auto and YOLO reduce repeated routine questions; they do not remove the
independent guards. Existing hard denials, configured restrictions, sensitive
paths, and explicit user constraints still apply. User-question tools,
opaque-token choices, maintenance or recovery consent, delegation control, and
native-review consent keep their own contracts. Neither mode discovers ambient
credentials or chooses an unknown remote destination for you.

Recognized destructive operations deserve special attention. YOLO retains fresh
confirmation or hard denial for broad deletion, destructive database actions,
and guarded Git operations. A force push, hard reset, or forced clean is
hard-blocked. Package-owned delegated children block recognized destructive
operations rather than prompting. There is a tightly defined exception for
recursive removal of a session's own temporary scratch under active YOLO; it is
not a general permission to remove temporary-looking paths.

Auto also keeps these guards. An allow verdict merely returns control to the
original executor and the remaining safeguards. Tool definitions and plugin
descriptions supplied as context are untrusted descriptions; a tool name does
not grant permission or prove that its implementation is safe.

## Why the guard is not containment

Auto can only classify the action and bounded context it receives. Its live
message window is limited; restate a restriction that must hold across a long
session. Script inspection does not execute the script and does not crawl its
dependencies. The recognition used for destructive shell commands is lexical,
not shell or SQL evaluation. Scripts, custom tools, prompt injection, and
unrecognized command forms can evade a semantic understanding of consequences.

Pi's security guidance therefore recommends a stronger design when the impact
matters: run it in a container, VM, or sandbox; expose only required files and
services; use narrowly scoped, short-lived credentials; and restrict network
access when it is unnecessary. Project trust controls startup loading of
project resources, but it also is not a limit on what enabled tools can access
after startup.

## Common mistakes

- **Treating YOLO as unlimited autonomy.** It is standing permission for
  ordinary *already-authorized* work, not scope expansion.
- **Treating Auto denial as a verdict on the task.** A timeout or unavailable
  classifier means the action did not run, not that the action is unsafe.
- **Saving a default by accident.** Session and default commands are separate.
- **Assuming children inherit the parent mode.** They retain bounded delegated
  scope and their own safety paths.
- **Using modes as isolation.** Use operating-system or virtualization
  boundaries and constrained credentials for containment.

## Try it

In an interactive primary session, run:

```text
/gentle:mode status
```

Read both fields before changing anything: the live mode tells you how this
session will handle eligible actions, while the saved default affects future
primary sessions. For a routine, tightly scoped task, explain which of Normal,
Auto, or YOLO you would choose and name the decision that would still require
you.

Next, **Native review** explains a different kind of control: evidence about a
frozen code candidate. It does not grant permission to deliver that candidate.
