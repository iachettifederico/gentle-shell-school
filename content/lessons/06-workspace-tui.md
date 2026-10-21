---
title: "The Workspace and Terminal UI"
slug: workspace-tui
description: "Navigate Pi and Gentle Shell's terminal workspace without mistaking views for hidden automation."
order: 6
quiz: true
agent_instructions: |
  Teach the workspace as an observable terminal interface. Cover Pi's editor,
  transcript, command menu, fullscreen and regular modes, then Gentle Shell's
  command palette, Changes view, and Agents view. Explain how to discover the
  shortcuts actually active in the student's session.

  Ask these questions with ask_user_question, including the correct answer:
  1. What opens Pi's command search?
     Correct answer: Typing `/` in the terminal editor.
  2. What command shows the active Pi shortcuts?
     Correct answer: `/hotkeys`.
  3. What opens Gentle Changes by default?
     Correct answer: `/gentle:changes` or `alt+g`.
  4. What does the Gentle Changes view compare against?
     Correct answer: The current Git working tree against HEAD, including
     untracked files.

  Have the student run `/hotkeys`, then open `/gentle:commands` if Gentle Shell
  is loaded. The lesson is done when they can find a command without memorizing
  it and can explain the difference between Pi's command menu and Gentle Shell's
  curated command palette.
---

# The Workspace and Terminal UI

A coding agent should be inspectable while it works. Pi provides the terminal
conversation interface; Gentle Shell adds workspace views around the same Pi
session. These interfaces improve visibility and navigation, but they do not
make work happen by themselves. You still read commands, inspect diffs, and make
decisions about the repository.

## Learn the Pi surface first

Pi’s interactive terminal has a transcript, an editor, and status information.
The transcript shows prompts, responses, tool calls, results, and errors. The
editor is where you write the next prompt. The footer reports the working folder,
session, model, context usage, and accumulated usage and cost.

A few direct controls are worth learning before any custom workspace shortcut:

- **Enter** submits a prompt; **Shift+Enter** inserts a line break.
- **Ctrl+G** opens a longer prompt in the configured external editor.
- Type **`@`** to search for a file to add to a prompt; **Tab** completes a path.
- **Ctrl+O** expands or collapses tool output.
- **Ctrl+T** shows or hides thinking blocks.
- **Escape** stops the current task.
- **Alt+Enter** queues follow-up work, and **Alt+Up** restores queued messages
  to the editor.

Pi has two display modes. Fullscreen mode keeps the editor and status area fixed
while the transcript scrolls inside the terminal; regular mode uses ordinary
terminal scrollback. Choose a mode with `/settings` or the `--tui-mode` option.
Mouse behavior and some shortcuts depend on terminal support, so do not rely on
pointer interaction without a keyboard route.

## Commands are discoverable, not a memory test

Type `/` in the editor to search commands available in the current session. The
menu is authoritative because extensions, prompt templates, and skills can add
commands. Pi’s built-in session commands include `/new`, `/resume`, `/tree`,
`/fork`, `/clone`, and `/compact`; model commands include `/model`, `/thinking`,
`/login`, and `/settings`.

Run `/hotkeys` to see active keyboard shortcuts in the current session. This is
better than assuming defaults, because keybindings can be changed in the agent
directory’s `keybindings.json`. After editing that file, `/reload` applies it to
the active session.

The defaults illustrate the pattern: `Ctrl+L` opens the model selector,
`Shift+Tab` cycles a supported thinking level, `Ctrl+O` expands tool output, and
`Ctrl+X` copies the relevant assistant message. In fullscreen mode, transcript
navigation actions can take precedence over editor actions using the same key.
That is a reason to consult `/hotkeys` when a familiar key behaves differently.

## Gentle Shell adds a curated palette

Gentle Shell has its own command palette:

```text
/gentle:commands
```

By default, **Alt+K** opens it. The palette is curated rather than a raw list of
every registered command. It groups available entries under Configuration,
Session, Diagnostics, and Skills, and searches by human label, command name, or
description. An entry appears only when it is both curated and registered.

This is different from Pi’s `/` menu. Pi’s menu searches all commands currently
available in the session; the Gentle Shell palette is an intentionally selected
workspace surface. Use the first to discover general session commands and the
second to reach common Gentle Shell controls quickly. The palette shortcut can
be rebound with `GENTLE_PI_COMMANDS_KEY`; setting it to `off` disables it.

## Gentle Changes makes Git state visible

Open the full Changes view with:

```text
/gentle:changes
```

The default shortcut is **Alt+G**. It shows the current Git state against
`HEAD`, including untracked files, for the session repository and relevant
subagent worktrees. This is a Git-based view, not a statement that the agent
made every edit: changes from your editor, shell commands, or other tools appear
too.

The two-pane view groups roots on the left and shows a selected diff on the
right. `j`/`k` or arrow keys navigate; **F** toggles a diff-only reading mode;
`o` or Enter opens the real file in the configured editor; and `q` or Escape
closes. The viewer reads diffs lazily and has an explicit bound for one selected
diff, so an oversized diff is offered to the editor rather than rendered without
limit.

The key idea is scope. A committed change disappears from the Changes view
because Git no longer reports it as uncommitted. A removed worktree disappears
because its directory is gone. The view answers “what is uncommitted here?”—not
“what did the agent do forever?”

## Gentle Agents keeps delegated work observable

Gentle Agents is a separate view for subagent work. Its live card stays above
the editor, and `/gentle:agents` or **Alt+A** opens a full-terminal overlay.
The overlay preserves task threads, model, token, cost, elapsed time, outcomes,
and history. Background results return as cards that start a new turn; the
parent need not poll to discover them.

This makes delegation legible, but it does not transfer responsibility. Each
subagent is its own Pi child process, and the parent session remains the place
where scope, evidence, and next actions are coordinated. The later lesson
**Delegation** explains roles and boundaries; here, use the view to see what is
actually running rather than guessing from a quiet terminal.

## Configure without confusing configuration with behavior

Pi lets you change keybindings in `keybindings.json`; Gentle Shell lets you
rebind several workspace shortcuts through named environment variables. Both
are interface choices. They do not alter Pi’s underlying agent loop, Git’s state,
or the need to verify behavior.

When a terminal looks wrong, start with `/hotkeys`, `/settings`, and the
current mode. When a workspace feature is absent, use the command menu or
palette to see what is registered instead of assuming every package is loaded.

## Common mistakes

- **Treating the palette as Pi’s complete command list.** It is curated.
- **Assuming a visible diff is agent attribution.** Changes reflects Git state.
- **Using old shortcut notes instead of `/hotkeys`.** Bindings are configurable.
- **Using mouse-only navigation.** Regular terminal mode leaves mouse input to
  the terminal, so every workflow needs a keyboard path.
- **Assuming a closed Agents card means work never ran.** Inspect the task view
  and session state when you need history.

## Try it

Run `/hotkeys` and find the binding for model selection or tool-output expansion.
Then open `/gentle:commands` and search for a registered workspace command. Open
`/gentle:changes` in a repository with a harmless uncommitted change, and
identify what comparison the diff is showing. Close each view with its displayed
keyboard route rather than relying on the mouse.
