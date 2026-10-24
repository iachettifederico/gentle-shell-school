---
title: "Feature Tracking"
slug: feature-tracking
description: "Keep large work recoverable with one feature document, a memory mirror, and a todo projection."
order: 13
module: "Organic Driven Development"
quiz: true
agent_instructions: |
  Teach the anatomy and authority boundaries of an ODD feature document. Explain
  why local progress is written first, how the Engram mirror and Todo projection
  differ, and what a parent reconciles on resume.

  Ask these questions with ask_user_question, including the correct answer:
  1. When is an ODD feature document created?
     Correct answer: Before the first write for large authorized implementation.
  2. Which section contains verbatim user requirements?
     Correct answer: Specs.
  3. Is the Todo UI another source of truth?
     Correct answer: No; it is a projection of the feature document.
  4. What happens if Engram is unavailable?
     Correct answer: Preserve local progress and explicitly record the mirror as
     pending; do not claim it succeeded or block unrelated safe work.

  Have the student open a feature document and identify its header, Specs,
  Tasks, and Log: a real `odd/tasks/*.md` file if they have one, otherwise this
  course's own public sample at
  https://github.com/iachettifederico/gentle-shell-school/blob/main/odd/tasks/phase-11-single-path.md. Have them name one task ID and its linked requirement.
  The lesson is done when they can explain how they would resume the feature by
  reconciling the task file, memory record, code, and verification evidence.
---

# Feature Tracking

Large work needs a recovery mechanism, not a pile of disconnected notes. In ODD,
that mechanism is **one feature document** at `odd/tasks/<feature-name>.md`.
It is the durable specification workers read by reference, the local record of
progress and proof, and the source from which the visible Todo list is derived.
When Engram is available, the parent mirrors the full document in project-scoped
memory under `odd/<feature-name>/tasks`.

The phrase “one document” matters. A separate plan, a partial memory summary,
and an independently edited todo list drift apart. ODD instead gives them clear
roles: the task file is the local authority, Engram is the recovery copy, and
Todo is a UI projection.

## When tracking begins

Tracking begins only for **large authorized implementation**, after exploration
and before the first write. A small, understood task needs no durable feature
artifact merely because a UI can show todos. Investigation and proposal-only
work remain read-only.

The parent creates the document automatically for large work; it does not ask
for separate task-tracking or storage permission. It chooses a descriptive,
filename-safe feature name and does not overwrite another feature. The parent
remains responsible for reconciliation even when it assigns a bounded task to a
worker.

## The document’s anatomy

The fixed order keeps stable intent above the growing history:

1. **Header:** two or three lines naming the objective, branch, delivery
   strategy, and test runner.
2. **`## Specs`:** numbered `S1` through `Sn` requirements, constraints, and
   acceptance criteria with their checks. Exact user strings, commands,
   examples, and error messages are quoted verbatim in the user’s language.
   They may be numbered and ordered, but not summarized or reworded. Assumptions
   are marked as assumptions rather than smuggled in as requirements.
3. **`## Tasks`:** stable task IDs, one line per task, linked `S#` items, route
   (inline or delegated), status, and commit identity or RED/GREEN evidence.
4. **`## Log`:** the logbook. `L1` contains the original request verbatim;
   later user corrections are appended verbatim with their date. Meaningful
   rationale, verification evidence, progress, and the next step belong here.

This is why workers are asked to read a feature document until `## Log` before
editing. The stable material tells them what must be built without spending
context on the growing journal, while the parent retains the full record for
recovery.

## Verbatim requirements preserve intent

Exact text is more than formatting. Error messages, commands, examples, and
acceptance language often contain a detail that a condensed handoff loses.
Passing the document locator lets the worker read that evidence directly rather
than trusting an intermediary’s paraphrase. The parent forwards task IDs, linked
requirements, authorized scope, and checks; the worker has no authority to
expand unrelated tasks.

When an accepted user, review, or verification change alters the work, update
intent and tasks together. Preserve valid completed and unrelated work; add a
new task or reopen an invalidated task with a reason and revised checks.
Findings alone do not authorize scope expansion. Routine corrections stay close
to their tasks. A checkbox requires observed proof, not an attempt.

## Local first, memory second

The parent writes local progress first, then mirrors the **full current
document** and repository-relative locator to Engram, and reads back both
because the writes are not atomic. If Engram is unavailable, local tracking
continues. Record that the mirror is pending; do not claim persistence happened,
and do not block unrelated safe work. When it becomes available, resynchronize.

The mirror is not a license to overwrite the local file blindly. On resume, the
parent reads the full feature memory and the actual task file, then reconciles
requirements, code, verification proof, and conflicts. A missing copy is not
permission to overwrite the surviving one. Preserve irreconcilable versions and
ask about the actual conflict rather than silently choosing the newest timestamp.

## Todo is visible, not authoritative

For large work, the existing Todo tool is the session and UI projection. After
writing and reconciling the durable file and mirror, the parent creates or
rebuilds the Todo list from the same feature tasks before the first source write.
After task transitions or material plan changes, it updates durable copies and
the projection in the same turn.

A Todo replay, or clearing completed items, must never delete or replace the
feature file or memory mirror. If the projection is unavailable, record that
limitation honestly. If direction changes, mark tasks `dropped` with a reason in
the Log; do not label them done. If an outside person or authorization is
required, mark the task `blocked` with the observable condition that unblocks
it. A prerequisite within the list is ordering, not blocking.

## A resume walkthrough

Suppose a session ends after two of five tasks. To resume, do not infer active
work from the newest global memory. Retrieve the project and feature-specific
memory, read the actual `odd/tasks` file, and inspect the repository’s code and
recorded proof. Compare the requirements with the diff and test evidence.
Preserve a pending mirror or conflicting edits. Then choose the next unfinished
task and refresh its scope and checks before implementation.

This routine is what makes large work recoverable: it treats the document as a
living account of intent and evidence, not a stale plan that the code has already
outgrown.

## Common mistakes

- **Creating tracking for small work.** It creates bureaucracy without a recovery
  need.
- **Putting a paraphrase in Specs.** Quote the user’s exact requirement.
- **Treating Todo as authority.** It is a projection and can be stale.
- **Replacing a whole document for one task update.** Make targeted edits so
  unrelated progress remains intact.
- **Claiming a failed memory write worked.** Mark it pending.

## Try it

Open a feature document in `odd/tasks/`. If you do not have one yet, use this
course's own
[Phase 11 feature document](https://github.com/iachettifederico/gentle-shell-school/blob/main/odd/tasks/phase-11-single-path.md).
Locate `S1`, one task linked to an
`S#`, and a Log entry with evidence. Imagine the local file and memory copy
conflict after an interruption. List what you would compare—requirements, code,
and observed checks—before deciding the next step. That is the recovery habit
that lets a feature survive a session boundary.
