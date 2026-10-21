---
title: "Writing Skills"
slug: writing-skills
description: "Create concise, reusable LLM instruction contracts that make recurring work safer and clearer."
order: 19
quiz: true
agent_instructions: |
  Teach how to decide whether a skill is warranted, then teach the required
  package style: focused runtime instructions, frontmatter, section order,
  decision gates, supporting files, and registry refresh. Emphasize preserving
  author intent when improving an existing skill.

  Ask these questions with ask_user_question, one at a time:
  1. What problem is a skill meant to solve? Correct answer: a recurring
  workflow or convention that benefits from reusable LLM runtime instructions,
  decision gates, and an output contract.
  2. Name one case where a skill should not be created. Correct answer: a
  one-off task, generic human documentation, or a rule better enforced by code,
  tests, or a linter.
  3. What section order does the Gentle AI style guide require? Correct answer:
  Activation Contract, Hard Rules, Decision Gates, Execution Steps, Output
  Contract, References.
  4. What should happen after a project skill is created, moved, renamed, or
  removed? Correct answer: refresh the skill registry when available.

  Perform this concrete setup check: have the student inspect one existing
  SKILL.md and identify its frontmatter description, activation contract, and
  output contract. They must not edit it unless they explicitly intend to make a
  reusable change. Done means the student can justify creating a skill rather
  than a template or documentation, and can outline a valid skill without
  inventing project policy.
---

# Writing Skills

A good skill changes what an agent reliably does in a recurring situation. It is
not an article about a topic and not a place to collect every team preference.
It is a compact **runtime instruction contract**: it tells a future agent when
to activate, which constraints cannot be relaxed, how to choose between cases,
how to execute, and what evidence to return. This focus is what makes a skill
more useful than a long prompt pasted into each session.

Before writing one, test whether the problem is actually reusable. Create or
update a skill when a workflow or convention repeats across sessions, local
constraints differ from generic practice, a decision tree makes a choice safer,
or templates, schemas, and references would improve repeatability. Do **not**
create a skill for a one-off task, generic documentation, or rules that should
be enforced by executable code, tests, or a linter. Those alternatives provide
stronger guarantees than model instructions.

This boundary also protects context. A skill that merely restates a README adds
another place for instructions to drift. A narrow skill can instead encode the
operational decisions an agent repeatedly needs to make. If the need is only a
reused slash-command prompt, choose a prompt template instead; see **Prompt
Templates**. If the need is executable behavior, consider an extension rather
than disguising program logic as prose.

## Start with the contract, not the filename

Gentle AI's style guide uses this portable directory shape:

```text
skills/{skill-name}/
├── SKILL.md
├── assets/       # optional: templates, schemas, examples, fixtures
└── references/   # optional: longer local docs or rationale
```

`SKILL.md` is concise because it is read as working context. The package target
is 180–450 tokens, with a recommended maximum of 700 and a hard maximum of
1,000. That budget is not an invitation to remove important rules. Instead,
move long examples, generated templates, schemas, and background rationale into
local `assets/` or `references/` files. References should point to files that
ship with the project or package, so the runtime contract does not depend on an
unexamined external page.

Use YAML frontmatter with a kebab-case name that normally matches the directory,
a one-line quoted description, a license, and metadata:

```yaml
---
name: release-notes
description: "Trigger: release notes, changelog draft. Draft release notes from verified changes."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---
```

The example exposes two important constraints: the description is one physical
YAML-safe line, and it starts with trigger phrases. It needs to
say both *when* the skill applies and *what* it does, because discovery depends
on that text. Do not add a separate `Keywords` section; put essential routing
words in the description.

## Give the agent an ordered decision path

The required section order is deliberate:

1. **Activation Contract**
2. **Hard Rules**
3. **Decision Gates**
4. **Execution Steps**
5. **Output Contract**
6. **References**

The activation contract says when to use the skill and when not to. Hard rules
make non-negotiable boundaries visible. Decision gates turn branching prose into
a compact table, which helps an agent avoid both unsafe overreach and unnecessary
ceremony. Execution steps describe the smallest repeatable sequence. The output
contract names what to report, commonly changed files, verification performed,
registry refresh needs, unresolved ambiguity, and remaining risk. References
point to the detailed local material that the agent should consult.

Write imperative instructions, not explanatory tutorial prose. Prefer bullets
and decision tables to paragraphs. Keep rules concrete: “read the style guide
before editing” gives an action; “be careful with quality” does not. Do not
invent domain policies, triggers, or constraints to make a skill look complete.
When a necessary rule is ambiguous, ask or mark the ambiguity for human review.

Here is a small decision-gate pattern:

```markdown
| Situation | Action |
| --- | --- |
| An existing skill already covers the workflow | Update it instead of creating a duplicate |
| Templates or fixtures are needed | Put them in `assets/` |
| A rule is unclear | Report it; do not rewrite it automatically |
```

The table does more than improve formatting. It forces a future agent to handle
known forks predictably and makes review easier: a reviewer can ask whether the
stated situations have a safe action.

## Create, then improve without erasing intent

The bundled `gentle-ai-skill-creator` skill provides an authoring workflow. It
starts by clarifying reusable behavior, runtime, trigger phrases, and non-goals
when they are not obvious. It inspects existing skills before creating a new
one, uses the required frontmatter and section order, and calls for a registry
refresh after project-skill changes. The `/skill-creation` prompt template can
start the same workflow:

```text
/skill-creation <skill idea or name>
```

A new skill is not always the answer. The skill-creator decision gates say to
update an existing skill when it already covers the behavior. This limits
competing instructions with overlapping triggers.

For an existing skill, use the `gentle-ai-skill-improver` workflow. It defaults
to audit-only: read the style guide and registry, inspect metadata, trigger
clarity, section order, body budget, actionability, decision gates, output
contract, and local references; then return proposed changes. It modifies files
only when the user explicitly asks to apply improvements. Preserve the author's
intent, critical rules, activation semantics, and output requirements. Never
delete meaningful content silently; move long material to a supporting file
when that preserves the contract.

## Finish the ecosystem work

Pi discovers a valid project `SKILL.md` directly. The Gentle AI skill registry
is a separate index for delegation: it records available names, descriptions, scopes, and exact paths;
the source file remains authoritative. After creating, removing, moving, or
renaming a project skill, refresh it when available:

```text
/skill-registry:refresh
```

For packaged gentle-pi skills, the creator workflow additionally calls for
adding the skill to `scripts/verify-package-files.mjs`. That makes the package
contents check aware of the new shipped file. The **Skills** lesson explains
how Pi discovers skills and how the registry lets a delegator pass exact paths
to a worker rather than paraphrasing their rules.

## Try it

Choose a repeated problem from your own project. Before writing anything, state
its trigger, its non-goal, and why a test or ordinary documentation would not be
a better solution. Inspect an existing related skill to avoid duplication. Draft
only its frontmatter and six section headings, then ask whether each heading can
contain a concrete instruction or decision. If the workflow is not truly
reusable, stop there—that is a successful design decision.

A completed skill is small enough to load when needed, specific enough to route
correctly, and explicit enough that an agent can return verifiable results
without turning project conventions into invented policy.
