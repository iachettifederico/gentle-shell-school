---
title: "Model Profiles and Routing"
slug: model-profiles
description: "Assign models deliberately to the orchestrator and focused roles."
order: 17
module: "Delegation"
quiz: true
agent_instructions: |
  Teach model routing as a deliberate, per-role configuration choice. Explain
  provider/model identifiers, named profiles, session-bound routing, repository
  pins, and why cost savings must preserve the role's required capability.

  Ask these questions with ask_user_question:
  1. What format identifies a routed model? Correct answer: provider/model.
  2. Which provider prefix should be used for OpenAI models in this course's
     examples? Correct answer: openai-codex, not bare openai.
  3. What does a named profile route atomically? Correct answer: the
     orchestrator's model and effort independently from packaged and review
     roles.
  4. Why is assigning the cheapest model to every role a mistake? Correct
     answer: routing must still meet the role's accuracy and reasoning needs.

  Check the student's real setup: have them open `/gentle:profiles` (the one
  models screen; `/gentle:models` is retired) and identify the effective
  routing shown there and which tab carries `◉` and `★`. Teach the difference
  between Use in this session, Make default, and Save. If those controls are unavailable, have them inspect the shape
  of ~/.gentle-shell/agent/subagents.json without revealing credentials or
  personal model choices.

  Done means the student can read provider/model identifiers, explain the
  distinction between an orchestrator profile and per-agent routing, and sketch
  a generic role-to-model plan that trades cost against the work's demands.
---

# Model Profiles and Routing

A model choice is part of a work plan. It affects cost, latency, and the
quality of the reasoning available to a particular job. The useful question is
not “which model is best?” It is “what capability does this role need, and what
is the least costly route that still supplies it?” Gentle Shell makes that
question explicit through profiles and per-agent routing instead of silently
letting every helper inherit an accidental default.

Model identifiers use the format `provider/model`. The provider is not cosmetic:
it identifies the route used to obtain the model. When using OpenAI models in
these examples, use the `openai-codex` provider rather than bare `openai`.
For example, a valid-shaped identifier is:

```text
openai-codex/<model>
```

`<model>` is a placeholder, not a recommendation or a value copied from
someone else's setup. What models you can actually select depends on the
providers and credentials available in your installation. Do not infer that a
model named in a configuration example is available to you.

## Context-aware runtime limit

The runtime sizes the parent session's context backstop from its resolved model:
`min(150k tokens, 0.15 × context window)`. You can configure it with
`GENTLE_PI_CONTEXT_BACKSTOP_TOKENS` and `GENTLE_PI_CONTEXT_BACKSTOP_FRACTION`.
That makes model context capacity an operational routing input, rather than a
reason to guess when a long session should delegate its next bounded unit.

## Two related routing controls

Gentle Shell describes named profiles as a way to route the orchestrator
atomically: a profile can choose the orchestrator's model and effort together.
It does so independently from packaged and review roles. The active profile is
bound to the parent session, and routing applies per session. A repository may
pin a profile so its subagents stop following the globally active profile. The
profiles interface shows the effective routing the runtime is using, which is
more useful than guessing from an old settings file.

Per-agent routing is complementary. The subagent configuration has a
`model_profiles` map whose keys are agent names and whose values can contain a
`model` identifier. Its *shape* can be represented without exposing anybody's
personal choices:

```json
{
  "model_profiles": {
    "gentle-ai-explore": { "model": "provider/reading-model" },
    "gentle-ai-worker": { "model": "provider/writing-model" },
    "gentle-ai-verify": { "model": "provider/review-model" }
  }
}
```

This is a generic example, not a catalog of installed models. It teaches the
mechanism: the named role is the stable routing target, while the model string
is the provider-qualified choice. Keep configuration and credentials separate;
a model profile is not a place to publish tokens or private account details.

## Route by role, not by prestige

The explorer, worker, and verifier do different work. An explorer compresses
read-only investigation into evidence and uncertainty. A worker reads a bounded
specification, edits authorized surfaces, and checks the result. A verifier is
an independent read-only check. Giving all three the same expensive route can
waste budget when the exploration is routine; giving all three the cheapest
route can undermine a difficult implementation or review.

A cost-aware plan therefore starts with the role's failure mode. Heavy reading
and routine mapping can often use a cheaper or subscription-backed model when
it can reliably produce an evidence-backed map. Heavy writing needs enough
capacity to follow detailed requirements, preserve local conventions, and
self-verify. Independent verification needs enough care to challenge a writer's
assumptions; it should not be selected merely because it is the same model that
wrote the change.

That is a tradeoff, not a universal hierarchy. A narrow familiar change may
need no delegation and no extra route at all. A high-risk change may justify a
stronger independent verifier. The parent still chooses topology first: model
cost never creates permission to delegate, and an inexpensive model never
makes a vague task safe.

## Configure without losing the thread

The generic configuration pattern above is intentionally small. First choose
roles. Then decide whether a session profile or repository pin should govern
the parent session. Then map each configured helper role to a
`provider/model` value you have confirmed is available. Finally, use the
runtime's effective-routing display to verify what will actually happen.

Session profile records support explicit model selections and thinking choices.
A saved binding is a snapshot: it can contain role model entries such as
`{"worker":{"model":"provider/model"}}`. Valid thinking takes precedence
over the older `effort` field where both appear. The record format is a
persistence contract, not an invitation to hand-edit session history; let the
supported controls make selections.

A packaged agent can also declare a default model in its definition. Routing
configuration lets the user's selected profile override the accidental nature
of that default. The result is predictable: the role stays recognizable while
the model choice remains yours.

## One models screen: `/gentle:profiles`

```text
/gentle:profiles
```

opens the models screen on the profile this repository resolves: one table,
with your profiles as tabs across the top. It replaces the retired
`/gentle:models`. Tab symbols show where a profile is in effect: `◉` this
session, `★` the default for new sessions, `⌂` this repository. Leaving a tab
with unsaved edits asks first: **Save and switch**, **Discard**, or **Stay**.

The table is that profile's routing. The orchestrator is the first row and the
agents follow; `enter` picks a model and `e` picks an effort from the levels
that model supports. Changing every agent at once through the `Model ▾` or
`Effort ▾` header never touches the orchestrator row.

Three buttons decide where the profile applies, and they are the heart of this
lesson:

- **Use in this session** (`u`) binds the profile to this Pi session only and
  switches its orchestrator. It writes no shared routing, defaults, or pins,
  but pending table edits are saved to the profile first, as **Save** would.
- **Make default** (`d`) makes it the default for new sessions through a
  guarded global apply (diff confirmation, rollback). Inside a repository
  pinned to a profile it re-pins that repository instead of moving global
  routing.
- **Save** (`s` or `ctrl+s`) writes what you see into the profile, nothing
  more.

The profile menu (`▾` on the active tab, or `m`) holds **Rename**,
**Duplicate**, **Use in this repo** (the clone-local pin), and **Delete**;
**+ New** (`n`) copies the current profile, captures what is running now, or
starts empty. File operations are subcommands: `/gentle:profiles export
<name>`, `import`, and `publish <name>` (the shared repository declaration),
plus `export-routing` and `restore-routing` for the global routing file.

## Common mistakes

The first mistake is omitting the provider prefix. `model-name` alone does not
say which provider route should serve it. The second is using bare `openai`
when the intended route is `openai-codex/<model>`. The third is copying another
person's `subagents.json` verbatim. It may encode unavailable models or private
preferences and does not teach the decision behind the choices.

The fourth is equating “cheaper” with “safe.” Savings come from matching the
model to bounded work, avoiding unneeded delegation, and keeping handoffs
precise. They do not come from weakening independent review or silently
changing a repository's routing policy.

## Try it

Open your profile or model controls and note the effective route shown for the
parent session. Next, make a paper plan for a hypothetical feature: identify
one read-heavy exploration task, one write task, and one verification task.
For each, write a generic `provider/model` route and one sentence explaining
why its cost and capability fit the role. Replace placeholders only after you
have confirmed what your own installation makes available.
