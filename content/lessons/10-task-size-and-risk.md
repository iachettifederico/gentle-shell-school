---
title: "Task Size and Risk"
slug: task-size-and-risk
description: "Classify work by understanding, resumability, and consequences—not counts."
order: 10
quiz: true
agent_instructions: |
  Teach the small/large classification and the high-risk list. Make clear that
  size and risk are separate: a small task can be high risk, and line or file
  counts never decide classification. Explain the required Risk line.

  Ask these questions with ask_user_question, including the correct answer:
  1. What three conditions make work small?
     Correct answer: It is understood, has contained risk, and is resumable from
     the original request plus git diff.
  2. Do many files or tests make a task large by themselves?
     Correct answer: No.
  3. Name one high-risk category.
     Correct answer: Data or irreversible effects, security, breaking an
     existing contract, concurrency, delivery or environment, or a change with
     no test able to catch regression.
  4. What Risk line should close a code change with no high-risk item?
     Correct answer: Risk: none.

  Have the student inspect `git diff` in a repository with changes, if one is
  available, and apply the resume test to a named request. Then ask them to
  identify the applicable Risk line. The lesson is done when they can explain
  their classification using all three small-task conditions and name the risk
  result without relying on counts.
---

# Task Size and Risk

“Small” is often used to mean “not many lines.” In ODD, that is not what it
means. A two-line change may be dangerous; a multi-file change may be routine
and easily recoverable. Task size decides whether work needs durable tracking.
Risk decides whether a mistake could be hard to detect, hard to undo, or reach
beyond the change. Keep the two decisions separate.

## The definition of small

A task is small only when **all three** conditions hold:

1. **Understood:** the outcome, what changes, and where it changes are known;
   no product or design decision remains open; this is established in one
   bounded read batch.
2. **Contained risk:** it touches no named high-risk item.
3. **Resumable from the diff:** if the session stopped now, someone could finish
   using the original request and `git diff` alone.

If all three are true, use the small path: direct inline work, applicable
focused checks and suite checks, and no feature document or memory mirror unless
the user asks for them. A todo is optional. The small path is deliberately
lightweight because it already has enough context to recover.

Work is large only when the resume test fails. Several sessions may be needed;
an external wait may interrupt it; requirements may be lost through compaction;
or the deliverables may need a durable sequence. Then ODD tracks it. Large work
does not automatically need a writer: delegation needs its own reason, such as
parallel independent units or a context backstop.

## Counts are evidence at most, never the rule

The number of files, commands, tests, fixes, or requested todo items does not
classify a task. Neither does a request’s line count. A large diff can still be
fully understood and resumable; a tiny change in authentication can have high
consequence. Counting is tempting because it is visible, but it substitutes a
proxy for the actual questions: do we understand the work, can we recover it,
and are the consequences contained?

About 400 authored changed lines is an advisory planning heuristic for coherent
work units and review load. It is not a task-size cap, an acceptance criterion,
or an automatic stop. Never delete comments, whitespace, docs, or tests, or
compress code, merely to meet it. Lesson **Commits and Slices** explains how the
review budget is used after classification.

## High-risk work

A change is high risk when a mistake would be difficult to find, difficult to
reverse, or reach beyond the local change. ODD names six categories:

1. **Data or irreversible effects:** migrations, deleting or rewriting stored
   data, format changes, or writing data without validation.
2. **Security:** authentication, permissions, credentials, secrets, guards, or
   sandbox boundaries.
3. **Existing contracts:** changing or removing a public API, CLI flag,
   configuration format, export, or mirrored prompt that others already use.
4. **Concurrency.**
5. **Delivery or environment:** installers, releases, CI, deployment, or
   dependencies.
6. **No regression test:** a change for which no test would catch a regression.

Not every new API field or requested behavior is a breaking contract change. The
category is about unrequested breaks in behavior that other consumers already
rely on. Likewise, “unclear” counts as high risk only when a bounded look cannot
tell whether one of the first five categories applies.

High risk changes the verification route, not the need to understand the work.
A named item gets writer self-verification and an independent verifier after the
change’s own checks. It does not mean all work needs an independent review just
because it is substantial. **Test-First and Verification** covers the evidence
route in detail.

## The Risk line

Close every code change—small or delegated—with a short, explicit statement:

```text
Risk: item 2 (authentication guard changes access)
```

or:

```text
Risk: none
```

The line makes the basis for verification observable. It names the numbered
high-risk category and a one-line reason when applicable. This prevents an
important routing choice from disappearing inside a vague summary. A native risk
assessment can refine its own tier when enabled, but it does not replace naming
a known high-risk item or lower the stated risk after a failed assessment.

## Classification examples

**Known copy correction.** The requested text and target view are clear; no
contract, data, or security implication is present; the diff shows exactly what
remains. This is small. Its Risk line is likely `Risk: none`.

**Change to a stored record format.** Even if the edit is only a few lines, data
or format compatibility is in play. It fails contained risk and belongs to high
risk. Explore the consequences and use the required verification route.

**A broad feature with a clear starting point.** You may know the first file to
edit, but if the original request plus a partial diff would not preserve the
remaining requirements and proof, it fails the resume test. It is large and
needs tracking before the first write.

## Common mistakes

- **“It is only one file.”** One file can contain a security or contract
  boundary.
- **“It has 500 lines, so it is large.”** The resume test, not volume, decides.
- **Calling all unclear work high risk immediately.** First take a bounded look;
  use high risk when that cannot determine categories 1–5.
- **Hiding risk in prose.** State the Risk line so the verification route has a
  visible basis.
- **Using a high-risk label as a reason to avoid implementation.** It calls for
  proportionate proof, not paralysis.

## Try it

Choose an upcoming repository change. For each small-task condition, write one
piece of evidence: what proves you understand it, why risk is or is not
contained, and whether a future contributor could resume from the request and
`git diff`. Then write its Risk line. If you cannot supply one of those pieces
of evidence, you have learned exactly what to explore or track next.
