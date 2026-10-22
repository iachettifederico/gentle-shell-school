---
title: "Extensions and packages"
slug: extensions-and-packages
description: "Add trusted executable behavior to Pi and distribute related resources together."
order: 26
module: "Power user"
quiz: true
agent_instructions: |
  Teach the difference between instructions, extensions, and packages; explain
  the trust boundary, lifecycle, resource discovery, and package scopes before
  commands. Relate this to the skills lesson without repeating it.

  Ask these questions with ask_user_question, and verify the answers:
  1. When should you choose an extension rather than a prompt template?
     Correct answer: when the workflow needs executable behavior such as tools,
     commands, event handlers, providers, session state, or terminal UI.
  2. Why must an extension source be trusted? Correct answer: it runs inside
     Pi with the same OS permissions and can inspect sensitive agent data.
  3. What does --local do for pi install? Correct answer: it writes the package
     declaration to project .pi/settings.json, which loads after project trust.
  4. Why are host-provided Pi packages peer dependencies? Correct answer: a
     physical duplicate can bypass Pi module mapping and create duplicate
     classes, registries, and initialization.

  Concrete setup check: ask the student to run pi list and identify whether a
  configured package is personal or project-local. If none is configured, have
  them locate the extensions, skills, prompts, and themes directories described
  by their agent directory instead; do not install anything merely for the lesson.
  Done means the student can choose the smallest suitable customization surface
  and explain the trust and scope of a package before loading it.
---

# Extensions and packages

Prompts and skills change what the model is told. Extensions change what Pi can
do. That boundary is the first design decision: choose instructions for a
repeatable human-guided workflow, but choose an extension when the workflow
needs executable behavior—tools, slash commands, event handlers, providers,
session state, or terminal UI.

An extension is a TypeScript or JavaScript module running inside the Pi process.
That is powerful and deliberately not casual: it has the same operating-system
permissions as Pi and can inspect prompts, tool calls, files, credentials, and
session history. Load only source you trust. A package can bundle extensions
with skills, templates, themes, and runtime dependencies, so it is also code
review territory rather than just a styling preference.

This lesson builds on **Skills** and **Writing skills**. Keep reusable guidance
in a skill when no code must execute. Use a prompt template for a reusable slash
command that expands to text. Reach for an extension only after you can name the
runtime capability that instructions cannot supply.

## The extension model

An extension exports a default factory receiving `ExtensionAPI`. The factory
registers capabilities for that runtime. A small command extension can register
a slash command; another might register a model-callable tool or an event
handler. Pi can load a local TypeScript file directly with `pi --extension
./hello.ts`; `jiti` means the local file does not need a separate compilation
step.

Choose a lifecycle boundary carefully. The factory may register things, but it
should not start long-lived processes, sockets, timers, or watchers: Pi can load
an extension without starting a session. Start session resources from
`session_start` or only when a command/tool requires them, and release them from
an idempotent `session_shutdown` handler. Reload replaces the runtime, so code
after `await ctx.reload()` must not reuse state from the old runtime.

Pi exposes several integration points:

- `pi.registerTool()` adds an operation the model can call.
- `pi.registerCommand()` adds a `/` command.
- `pi.on()` observes or transforms lifecycle behavior.
- `pi.registerProvider()` adds a model provider.
- `pi.registerMcpServer()` adds a server for the current session.
- `pi.appendEntry()` persists non-context session data.

Tools need a name, a model-facing description, a TypeBox parameter schema, and
an `execute()` function. A result has model-facing content plus optional details
for rendering or reconstruction. Tool calls from one assistant message can run
in parallel, so do not assume another sibling call has completed. If file
mutations share state, protect the entire read-modify-write operation with Pi's
file-mutation queue.

Tool exposure is another important mechanism. `direct` tools are declared to
the model. `codemode` tools are callable from scripts but not directly declared.
`deferred` tools are found through search, and `hidden` tools are registered but
unreachable. This permits a large capability set without turning every prompt
into a tool catalogue. It is not a security boundary by itself; permissions
still belong in the tool pipeline.

## Where extensions load

The agent directory conventionally contains `extensions/`; a trusted project can
contain `.pi/extensions/`. Settings can also list extension paths. User and
project resources have different implications: project configuration loads only
after project trust is granted. Review project declarations before granting that
trust because their extensions execute code.

Gentle Shell itself is an example of a package built from extensions. Its bundle
includes presentation and workflow capabilities such as Gentle Agents, Gentle
Todo, Gentle Stats, a NaN provider registration, questions and choices, status
and notification support, and a startup banner. The important lesson is not to
memorize those filenames. It is to recognize that a product can compose many
small runtime integrations while Pi remains the host process.

## Package a coherent customization

A Pi package is an ordinary directory or npm package that can distribute
extensions, skills, prompt templates, and themes together. A conventional layout
uses `extensions/`, `skills/`, `prompts/`, and `themes/`. Alternatively, the
`pi` key in `package.json` explicitly names resource paths and glob patterns.
Use a package when resources belong together or should be shared through npm or
git; do not create one merely to hold a single personal Markdown file.

Install sources with Pi rather than a general package-manager command:

```bash
pi install npm:@example/pi-tools@1.0.0
pi install git:github.com/example/pi-tools@v1
pi install ./local-package
pi list
```

A normal install is personal and writes to the agent settings. Add `--local` (or
`-l`) to declare it in `.pi/settings.json`; that declaration installs and loads
only after project trust. `pi remove <source>` removes one configured source,
and `pi update --extensions` reconciles package installations. A versioned npm
specification, Git tag, or commit is pinned, which makes the source you reviewed
more reproducible.

Package dependencies deserve the same boundary discipline. Runtime libraries
imported by extensions belong in `dependencies`. Pi host packages belong in
`peerDependencies` with a `"*"` range, not in dependencies, because a bundled
host copy can create duplicate classes and registries. Local packages are not
installed or modified by Pi, so their dependency tree remains the author's
responsibility.

Settings can narrow a package to selected extensions, skills, prompts, or
themes. Omitting a resource type loads what the package allows; an empty array
loads none of that type. These filters only narrow a package's own manifest—they
cannot expose an undeclared resource.

## Common mistakes

- Treating an extension as harmless configuration instead of executable code.
- Starting a watcher in the extension factory and leaking it across reloads.
- Putting a host-provided Pi library in `dependencies`.
- Declaring a project package without considering that trust gates its loading.
- Reimplementing a text-only workflow as code when a skill or template suffices.

## Try it

Run `pi list` to inspect configured packages without changing them. Then inspect
your agent directory's resource folders and identify one customization as a
skill, template, theme, or extension. Explain what executable capability, if
any, makes the extension choice necessary. That explanation is more valuable
than installing a demonstration package you do not intend to maintain.
