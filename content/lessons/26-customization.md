---
title: "Customization"
slug: customization
description: "Customize Pi and Gentle Shell deliberately while preserving clear configuration boundaries."
order: 26
module: "Power user"
quiz: true
agent_instructions: |
  Teach customization as a set of scoped, reviewable preferences. Cover Pi
  settings, themes, prompt templates, and Gentle Shell's Customize panel,
  including opt-in history and audio. Explain what changes live versus what
  needs reload without asking the student to expose personal configuration.

  Ask these questions with ask_user_question, and verify the answers:
  1. When do trusted project settings load? Correct answer: after project trust
     is granted, except sessionDir is read before trust.
  2. What is the difference between a theme and a prompt template? Correct
     answer: a theme changes presentation colors; a template expands reusable
     Markdown text into a slash command.
  3. Are prompt-history capture and audio notifications on by default? Correct
     answer: both are off by default.
  4. What is the safe response to an unfamiliar project extension, package, or
     template? Correct answer: review it before granting project trust because
     it may execute code or instruct the model to run programs.

  Concrete setup check: ask the student to open /gentle:customize and identify
  one current visual setting without changing it, then open /settings and name
  the active Pi theme. If their interface lacks either command, have them
  inspect their agent directory settings location instead. Done means the
  student can name the scope and persistence of a proposed customization and
  can make a small reversible change intentionally.
---

# Customization

A coding environment should fit your attention, not demand that you memorize a
private collection of switches. The useful distinction is not “configuration
versus no configuration”; it is **which layer owns a preference, where it
loads, and whether it can execute behavior**. That lets you make a terminal
more legible without accidentally turning a project checkout into a source of
unreviewed instructions or code.

Pi has user-level configuration in its agent directory, normally
`~/.pi/agent`, and project configuration in `.pi` beneath the working directory.
Project configuration loads after project trust is granted. The exception is
`sessionDir`, which Pi reads early so it can find sessions. Context files such
as `AGENTS.md` are different again: Pi discovers them from the agent directory,
working directory, and parent directories, and that discovery does not require
project trust.

## Settings: choose a scope before a value

`<agent-dir>/settings.json` holds user-level preferences, defaults, resource
paths, and package declarations. `.pi/settings.json` holds project-level
counterparts. Project settings override agent-directory settings, while resource
lists combine. Add Pi's published settings schema URL to a settings file when
you want editor validation and completion.

Use `/settings` for common interactive preferences. Manually edited settings,
keybindings, instructions, and resources need `/reload` in an active session.
The setting reference groups choices into model and thinking, interaction,
tools, sessions and context, display, network, shell, resources, and update
behavior. The grouping matters: a `theme` is a display choice, while
`defaultTools` controls which built-in tool set starts active.

For example, `defaultTools` uses plain names to replace defaults and `+name` or
`-name` to adjust an inherited selection. A project list containing only plus
and minus entries adjusts the user selection; one with a plain name replaces
it. That allows a project to enable `codemode` beside ordinary tools without
silently inventing a new base set.

Settings are not automatically harmless. Resource paths can load extensions,
skills, prompts, or themes; packages can include executable extensions. Keep
personal preferences personal, and inspect an unfamiliar project before
trusting it.

## Themes: presentation with a strict format

Themes control Pi colors in interactive mode and HTML exports. The default
`system` theme derives colors from the terminal's foreground, background, and
ANSI palette and adapts to light/dark changes. Pi also includes `dark` and
`light`. Select a theme in `/settings`, or use `--use-theme` for one invocation
without saving it.

A custom JSON theme conventionally lives at `<agent-dir>/themes/my-theme.json`.
Its `name` identifies it; `system` and names containing `/` are reserved. The
file can define `vars`, assign role-based `colors`, and optionally specify HTML
export colors. Theme objects are strict: unknown top-level fields and color
tokens are rejected. Put reusable custom values in `vars`, not improvised color
keys.

A user theme named for its file hot-reloads when it is active. For a theme from
another source, use `/reload` after a change. Project themes in `.pi/themes/`
are subject to project trust, just like other project resources. A theme alters
how information looks; it does not alter the agent's policy or tool authority.

## Prompt templates: reusable text, not code

A Markdown file in `<agent-dir>/prompts/` becomes a slash command. Its filename
is the command name, and optional frontmatter gives a description and argument
hint. For example, `review.md` creates `/review`; `$1`, `$@`, and default
substitutions place quoted command arguments into the text before the agent sees
it.

Templates suit stable prompts such as a review checklist. They do not add
executable behavior. Project templates are also gated by project trust because
their content can instruct a model to run programs. When choosing between this
and an extension, revisit **Extensions and packages**: text reuse is a
template; runtime behavior is an extension.

## Gentle Shell's Customize panel

`/gentle:customize` collects Gentle Shell's visual and workspace controls. It
can adjust animation quality, the startup banner, text logo and color, and an
installed Pi theme. It also controls status placement and density, visibility
of changes, agents, TODO, usage/cost, and model details. Layout changes apply
immediately; banner changes appear on the next startup.

The panel also exposes an explicit global Vim preference for the prompt editor.
Unsupported editors keep ordinary editing even if the saved preference is on.
Visual profiles can save and apply a selected installed theme, banner,
animation, and layout. They do not include Vim; that avoids conflating editing
semantics with visual appearance.

### Audio is intentional and local

Audio notifications are off by default. In `/gentle:customize` → Notifications,
the global switch, process mute, and success/error/attention type groups live in
one card; per-event overrides are folded under Advanced. Muting or disabling
discards pending events, and resuming does not replay them. Only the primary TUI
owner plays audio: child processes, print/JSON mode, and RPC are silent.

The panel can use built-in tones or a literal absolute local WAV path. It does
not accept URLs, relative paths, `~`, environment expansion, commands, or
configurable player executables. This makes sound selection a local-file choice,
not a covert command runner. Audio preferences are separate from visual
profiles and visual reset.

### History deserves the same care

Prompt history capture is also off by default because prompts can contain
secrets. Enable or disable it from the History category of `/gentle:customize`;
the change applies from the next prompt. An explicit `GENTLE_PI_HISTORY_CAPTURE`
environment value overrides the saved preference for that session or script.

Captured history is local plaintext JSONL, not encrypted, and can contain
prompts verbatim. Turning capture off stops new writes but does not delete what
was already stored. That is why a history preference is a privacy decision, not
merely a convenience toggle.

## Common mistakes

- Editing a project setting before checking whether it is trusted and who will
  inherit it.
- Calling a theme a policy mechanism or assuming it changes permissions.
- Using a template where an extension is required, or an extension where text
  reuse is enough.
- Enabling history without considering that delivered prompts may be sensitive.
- Expecting a visual profile to capture every non-visual preference.

## Try it

Open `/gentle:customize` and inspect one layout or display choice without
changing it. Then inspect `/settings` and identify the active theme. Choose one
small, reversible preference to change, observe whether it applies immediately
or after reload/startup, and record which scope owns it. This is how
customization remains a tool for clarity instead of an accidental second system.
