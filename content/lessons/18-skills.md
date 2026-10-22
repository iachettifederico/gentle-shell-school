---
title: "Skills"
slug: skills
description: "Learn how Pi discovers and loads focused instruction contracts for recurring work."
order: 18
module: "Memory and skills"
quiz: true
agent_instructions: |
  Teach skills as lazily loaded, focused instructions for recurring workflows.
  Contrast them with prompt templates and extensions, then explain discovery,
  routing descriptions, forced invocation, and the registry's role as an index.

  Ask these questions with ask_user_question, one at a time:
  1. What does Pi put in its system prompt at startup for an available skill?
     Correct answer: its name, description, and path, not the full instructions.
  2. When should a workflow use a skill instead of a prompt template? Correct
     answer: when it needs more context or supporting files, but not a new
     executable integration point.
  3. What is the source of truth after a registry is generated? Correct answer:
     the skill's SKILL.md; the registry is only an index.
  4. How can a user force a skill to load? Correct answer: use /skill:name.

  Perform this concrete setup check: have the student inspect their session's
  available skills or enter /skill:name for one shown skill, without running an
  unfamiliar skill that could modify their project. If no skills appear, have
  them identify a supported personal or project skill location. Done means the
  student can explain lazy loading, select a skill from its description, and
  distinguish a registry entry from the instructions it indexes.
---

# Skills

Coding agents accumulate two opposite kinds of context. Some instructions are
needed almost every time: safety boundaries, project conventions, and the live
request. Other instructions matter only for a narrow kind of work, such as
preparing a pull request, auditing a skill, or generating a document. Loading
every specialized procedure into every conversation wastes context and makes
important rules harder to notice. A Pi **skill** solves this by packaging a
focused instruction contract that loads when its workflow is relevant.

A portable skill is a directory containing `SKILL.md`. It can also carry files
that make the contract practical:

```text
pdf-tools/
├── SKILL.md
├── scripts/
│   └── extract.sh
├── references/
│   └── formats.md
└── assets/
    └── template.json
```

The `SKILL.md` file begins with frontmatter and then gives direct agent
instructions. Its name and description are especially important. At startup,
Pi scans configured skill locations and advertises each available skill's name,
description, and path in the system prompt. It does **not** add the complete
body. When the task matches, the model reads `SKILL.md` and follows its
instructions. That lazy-loading mechanism keeps a specialized procedure
available without paying for all of its detail on every request.

## Choose the right reusable mechanism

A skill is for a workflow that needs more context than a reusable prompt, but
does not need an executable integration point. It can bundle supporting scripts,
references, and assets alongside its instructions. For example, a skill can
teach an agent the decision gates and output contract for a recurring review
workflow, while keeping longer reference material in a nearby file.

A **prompt template** is lighter. It turns one Markdown file into a reusable
slash command and expands text into the agent conversation. Templates can take
arguments, but they are best when you want the same prompt again without
executable behavior or a larger set of supporting instructions. The **Prompt
Templates** lesson covers their argument substitution and command behavior.
An extension is different again: it supplies executable integration behavior.
Do not turn a small reusable prompt into a skill, or a skill into an extension,
unless its actual need crosses that boundary.

## Descriptions are routing, not decoration

Pi relies on the description to help the model decide whether to load a skill.
A description should state both what the skill does and when it applies. “Helps
with PDFs” leaves the route ambiguous; “Extract text and tables from PDF files.
Use when reading, converting, or inspecting PDFs” gives the agent a usable
trigger. A user can override uncertain automatic selection with:

```text
/skill:pdf-tools
```

Arguments after that command are appended to the loaded instructions as a user
request, so this is also valid:

```text
/skill:pdf-tools extract report.pdf
```

A skill may set `disable-model-invocation: true` in its frontmatter when it
should be available only through explicit invocation. The `enableSkillCommands`
setting controls whether interactive discovery shows skill commands; manually
entered `/skill:name` commands still work. These controls separate *available*
from *automatically selected*, which is useful for powerful or infrequent
workflows.

## Discovery, scope, and trust

Pi discovers `SKILL.md` directories recursively in configured skill locations.
It supports the Agent Skills locations `~/.agents/skills/` and `.agents/skills/`.
Project `.agents/skills/` directories are discovered from the working directory
through its ancestors, stopping at the repository root when one exists. Pi also
accepts some standalone Markdown skills, but a directory containing `SKILL.md`
is the portable form.

That convenience has a safety implication: a project skill can tell an agent to
run scripts or modify files. Review unfamiliar skills and their supporting files
before granting project trust. A malformed `SKILL.md`, or a declared skill with
no description, is not loaded. If skills share a name, Pi keeps the first one
discovered and emits a warning. Name and routing description are therefore part
of the behavior, not merely labels.

After adding or editing a skill during an active Pi session, run `/reload` so
Pi reloads it. To distribute skills through npm or Git, use a Pi package and
keep required environment setup in that package.

## The Gentle AI skill registry

Gentle AI adds a registry workflow for delegators. The generated
`.atl/skill-registry.md` is an index of skill names, trigger descriptions,
scopes, and exact `SKILL.md` paths. It is not a shortened substitute for the
skills themselves. A parent agent matches a task against the registry, passes
only relevant exact paths to a subagent, and tells that subagent to read those
files before work. This avoids copying lossy summaries into handoffs and lets
the skill remain the source of truth.

The registry skill says to refresh after installing, removing, creating, moving,
or renaming skills. Its refresh command is:

```text
/skill-registry:refresh
```

The package registry scans known project and user skill directories, excludes
`_shared`, `skill-registry`, and names beginning `sdd-`, and deduplicates by
skill name with a project skill preferred over a user skill. If no skills are
found, it writes an empty registry so agents stop searching blindly. The
extension can also refresh a registry after watched skill-directory changes;
the explicit command remains the deliberate way to regenerate it.

Bundled skills demonstrate the point: skill-registry indexes skills, while
skill-creator provides a runtime contract for creating reusable skills and
skill-improver provides an audit-first contract for improving existing ones.
The next lesson, **Writing Skills**, goes inside those authoring rules.

## Try it

Open a session and inspect the skill names and descriptions it exposes. Pick one
whose description clearly matches a task you might actually do; explain why its
trigger is specific enough. Then locate its `SKILL.md` before relying on it.
If you maintain project skills, refresh the registry after a deliberately
approved change and compare the index entry with the source file.

The outcome to aim for is proportion: keep common context small, load precise
workflow instructions only when they apply, and treat discovered instructions as
code-adjacent material worth reviewing before they direct real work.
