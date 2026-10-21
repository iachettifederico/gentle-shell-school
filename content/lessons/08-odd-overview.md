---
title: "Organic Driven Development"
slug: odd-overview
description: "Use ODD to turn an authorized request into recoverable, proportionate work."
order: 8
quiz: true
agent_instructions: |
  Teach Organic Driven Development as a proportional workflow rather than a
  ceremony. Explain the seven steps, especially the distinction between small
  work and large work, and why the durable feature document is only for large
  authorized implementation.

  Ask these questions with ask_user_question, including the correct answer:
  1. Before implementation is authorized, what kind of work is allowed?
     Correct answer: Read-only exploration.
  2. What makes a task large in ODD?
     Correct answer: It fails the resume test; counts alone do not decide it.
  3. What is the source of truth for substantial work?
     Correct answer: One feature document, mirrored in project-scoped Engram
     when memory is available.
  4. What must a completion report include?
     Correct answer: The verified outcome, failed or pending checks, and the
     next step.

  Have the student inspect an existing odd/tasks/*.md document in their current
  project, or run `find odd/tasks -maxdepth 1 -type f -name '*.md'` if it has
  one. Ask them to identify its Specs, Tasks, and Log sections. The lesson is
  done when they can classify a request as read-only, small authorized work, or
  large authorized work and explain the next ODD step.
---

# Organic Driven Development

A coding agent can appear productive while quietly making the work harder to
recover, review, or correct. It can start editing before it understands the
repository, turn a two-line fix into a planning ritual, or leave a large change
with no durable account of what was requested and what was proved. **Organic
Driven Development (ODD)** is the everyday workflow that avoids both extremes.

ODD is not a separate command or a rigid project-management system. It is a
routing discipline: explore before changing, resolve only real uncertainty, and
make the amount of process proportional to understanding, risk, and the chance
that work must be resumed later. This lesson covers the overall path. The next
lessons unpack authorization, sizing, tracking, verification, and reviewable
commits.

## The seven-step path

ODD runs for every request, whether or not the request mentions a plan.

1. **Authorize.** The agent is read-only until implementation is authorized. If
   intent is ambiguous, it asks one clarification.
2. **Explore.** Read the relevant code and requirements before changing them,
   with depth proportional to the request.
3. **Resolve uncertainty.** Research or ask one focused product question only
   when there is a real unresolved decision.
4. **Classify.** Decide whether the work is small or large using the resume
   test, not file counts or line counts.
5. **Track before the first write.** For large work, create one feature
   document and mirror it in project-scoped Engram when memory is available.
6. **Implement task by task.** Use the smallest safe workflow, applicable
   tests, and reviewable work units.
7. **Close.** State the verified result, failed or pending checks, and what
   should happen next.

The order is important. Exploration is not procrastination: it makes the first
write informed. Classification is not a guess about effort: it chooses whether
the work needs continuity. Closure is not a checkbox: it communicates the
actual proof and remaining uncertainty.

## Why proportional process matters

ODD deliberately has a light path. A small, understood request with contained
risk that someone could finish from the original request and `git diff` alone
does not need a feature document, memory mirror, or separate tracking artifact.
It stays inline. Investigation and proposal-only work also remain read-only.

Conversely, substantial authorized work needs a durable recovery point. An
interruption can otherwise lose the original constraints, which checks already
ran, why a task changed, and the next safe action. The feature document captures
that continuity without creating a second plan file or an exhaustive diary. Its
Engram mirror, when available, lets the parent recover the same record across
sessions.

This is why ODD is better understood as runtime discipline than prompt wording.
A prompt can ask an agent to be careful, but the workflow creates observable
boundaries: no write before authorization, exploration before implementation,
a concrete test for task size, a local record for substantial work, and truthful
verification at the end. The discipline changes what evidence exists when the
next person—or the same agent after an interruption—needs it.

## The resume test is the hinge

The classification question is practical: if the session stopped now, could
someone finish the request from the original request and `git diff` alone? If
yes, and risk is contained and the outcome is understood, the work is small.
If not, it is large. A task may be large because several sessions are likely,
requirements could be lost during compaction, or the deliverables need durable
coordination.

Counts do **not** classify a task. Many files, commands, tests, fixes, or a
requested todo list do not automatically make work large. Nor does a line-count
estimate. That prevents process from growing just because a change happens to
touch several files. Lesson **Task Size and Risk** gives this test more detail.

## One parent, one record

For large work, the parent session remains accountable even when bounded workers
help. It passes workers the feature-document locator, task IDs, linked
requirements, authorized scope, and checks. Workers read the document before
editing rather than receiving a lossy paraphrase. This protects exact strings,
error messages, examples, and acceptance criteria.

The parent also reconciles progress. Findings do not silently expand scope, and
a completed checkbox needs observed proof. If memory is unavailable, local
progress still comes first; an unavailable mirror is recorded as pending rather
than invented as success. Lesson **Feature Tracking** explains the record in
detail, while **Delegation** later explains when a bounded worker is useful.

## A compact example

Imagine: “Rename this button’s label.” If the location and desired label are
known, the risk is contained, and the change could be resumed from the request
and diff, this is small authorized work: inspect, edit, run an applicable check,
and report the result.

Now imagine: “Add a curriculum module with multiple lessons, validation, and a
reviewable delivery.” The task has multiple requirements and a likely recovery
need. After exploration, it should be tracked before writing. The document
preserves the specification, task-level evidence, and next step while each task
is implemented and checked.

## Common mistakes

- **Tracking every request.** This makes simple work slower without improving
  recovery. Use the resume test.
- **Treating exploration as permission to edit.** Reading and proposing remain
  read-only until implementation is authorized.
- **Using line count as a classifier.** It is not the size rule.
- **Checking off work because it was attempted.** Record only observed proof.
- **Calling the feature branch the review candidate.** ODD uses a work-unit
  commit or a PR slice, not an accumulated branch or a TODO checkbox.

## Try it

Find a request you could make in a repository. First write down what you would
need to inspect before editing. Then ask the resume question: if you stopped
after the first change, would the original request plus `git diff` tell another
person everything needed to finish? Use your answer to choose the small path or
the tracked path. In the following lessons, you will learn the precise rules for
that choice and the evidence each path needs.
