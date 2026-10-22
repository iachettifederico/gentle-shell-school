---
title: "Focused Subagents"
slug: subagents
description: "Delegate bounded work without giving up ownership of the outcome."
order: 14
module: "Delegation"
quiz: true
agent_instructions: |
  Teach why focused subagents are a coordination tool rather than a way to
  avoid responsibility. Cover the explore, worker, and verifier roles; the
  evidence-budget and writer triggers; and bounded handoffs with allowed edit
  surfaces.

  Ask these questions with ask_user_question:
  1. What is the explorer's output supposed to contain? Correct answer: a
     compressed, evidence-backed map and remaining uncertainty, not changes.
  2. When may parallel writers run? Correct answer: when there are two or more
     independent behavior units with disjoint edit surfaces and a named reason
     for parallelism.
  3. Who owns scope, user decisions, and the final summary after delegation?
     Correct answer: the parent orchestrator.
  4. What should a writer receive instead of a paraphrase of a tracked request?
     Correct answer: a reference to the feature document's Specs and the exact
     task and acceptance scope.

  Check the student's real setup: ask them to open the Gentle Agents view with
  /gentle:agents and describe whether it shows active work or no active
  subagents. Do not ask them to launch a task merely for this lesson.

  Done means the student can distinguish exploration, implementation, and
  independent verification; can explain when work should stay inline; and can
  describe a bounded handoff with an exact edit surface.
---

# Focused Subagents

A subagent is useful when it makes the parent session *more reliable*, not when
it merely creates more activity. Gentle Shell calls this arrangement focused
agents: one parent session remains accountable while specialists explore,
implement, or verify a bounded part of the work. The parent owns the scope,
human decisions, review disposition, and final report. A child returns evidence
and cannot turn its own output into permission to ship.

That division solves two ordinary problems. First, a broad unfamiliar codebase
can consume the parent context before implementation has even begun. Second,
separate pieces of genuinely independent work can take longer when completed
serially. Delegation gives each helper a fresh, narrow context and a return path
to the session that still knows the user's intent. It is not a default for every
multi-file request: coordination has setup cost and can hide dependencies.

## Three roles, three kinds of evidence

The packaged roles illustrate the boundary:

- **Explorer** is read-only. It maps relevant files, symbols, relationships,
  observed evidence, and uncertainty. It does not edit, run commands, commit,
  or fix findings. The one explicit exception: it may initialize a cwd-scoped
  CodeGraph index, which can create `.codegraph/`. Its job is to reduce an investigation to a handoff the
  parent can use to choose a route.
- **Worker** is a scoped implementation writer. It reads the task context,
  changes only its authorized surfaces, runs only parent-authorized checks, and
  reports what it observed. It does not delegate, commit, push, or own native
  review.
- **Verifier** is read-only and independent of the writer. It inspects the
  relevant evidence and runs only explicitly authorized checks. It reports
  results and gaps; it does not repair them.

Other packaged agents exist for specialized review workflows, but that does not
make them generic replacements for these roles. Pick the role whose output you
actually need. Asking an explorer to implement defeats its read-only evidence
boundary; asking a worker to make the final delivery decision defeats the
parent's ownership boundary.

## Decide whether to delegate

The parent delegates for a named reason, not for file count or a model-price
comparison. Work can stay inline when it is small and understood: read the
relevant files, make one coherent change, run its focused checks, and report.

Exploration is warranted when understanding will not fit the parent evidence
budget: more than one parallel batch of roughly three calls and about 10,000
tokens, or more than about five sequential lookups. The explorer should return
path-and-line evidence in a short handoff. Do not use an explorer for a small,
targeted question, and do not make it reread material the parent already needs
for an inline edit.

A writer is warranted only for a bounded unit with a named reason. One reason
is parallelism: two or more independent units of behavior, each substantial
enough to outweigh setup, with disjoint edit surfaces. Another is the runtime's
context backstop during a long session. A large task by itself is not enough.
If units depend on each other, or if they are small, do them inline in sequence.
When an independent high-risk item requires separate verification, the verifier
is an additional outside view after the writer's own checks, not a substitute
for those checks.

## Make the handoff executable

A useful handoff is a compact contract, not an essay. For tracked work, point
the child to the feature document and tell it to read the `## Specs` section
through `## Log`; do not paraphrase exact requirements. Name its role, task,
acceptance criteria, relevant prior evidence, and the exact commands it may run.
Technical artifacts and subagent-facing instructions default to English.

Most importantly, give a writer exact **allowed edit surfaces**: repository
relative paths or narrow globs, including any new-file directories it may use.
They must be derived by the parent before launch. A writer changes nothing
outside those surfaces, and parallel writers need disjoint surfaces (or
isolated worktrees). This is a practical concurrency mechanism: it makes an
overlapping edit a planning error rather than a surprise discovered in a merge.

For example, a parent might delegate a documentation unit like this:

```text
Spec: odd/tasks/search.md (read until "## Log"). Do T2; S1.
Role: worker.
Allowed edit surfaces:
- docs/search.md
- spec/docs/search_spec.rb
Verification:
- bin/rspec spec/docs/search_spec.rb
```

The example deliberately names both the behavior and its proof. It does not
transfer ownership of product choices or permission to expand scope.

## Observe, then integrate

Gentle Agents gives the parent a live view of subagent work. Open
`/gentle:agents` to see this session's active subagents; the view can also list
open orchestrators in the profile. A completed child returns a structured
handoff. Treat it as evidence to inspect, not as an instruction to trust
blindly. The parent reconciles independent results, runs required checks, and
reports what happened.

A common mistake is “delegating because this feels big.” That creates prompts,
waiting, and handoff interpretation without improving the decision. Another is
splitting a single behavior into a test writer, code writer, and documentation
writer. Those pieces share a contract and should move together. A third is a
vague surface such as the whole repository: it removes the boundary that makes
parallel work safe.

## Try it

Open `/gentle:agents`. Then take a recent task and write a three-line routing
note: whether it would stay inline or use an explorer/worker/verifier, the
specific reason, and the exact output you would require from that role. If you
would use a worker, list the smallest set of paths it may change. That exercise
is the skill: choose a topology that preserves a clear return path to you.
