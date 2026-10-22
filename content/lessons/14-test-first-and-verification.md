---
title: "Test-First and Verification"
slug: test-first-and-verification
description: "Produce observable proof with RED, GREEN, alternate cases, and proportionate verification."
order: 14
module: "Organic Driven Development"
quiz: true
agent_instructions: |
  Teach applicable test-first development and the verification rule. Distinguish
  a meaningful behavioral RED from passive-documentation exceptions, and explain
  why tests and native review are different kinds of evidence.

  Ask these questions with ask_user_question, including the correct answer:
  1. What sequence does applicable test-first work follow?
     Correct answer: Observed RED, minimum implementation and GREEN, relevant
     alternate cases, then REFACTOR with focused checks still passing.
  2. Does the existence of tests automatically make TDD applicable?
     Correct answer: No.
  3. What should be recorded when no meaningful RED is available?
     Correct answer: The specific exception rationale and proportionate ordinary
     functional or structural verification.
  4. What does a native code review not replace?
     Correct answer: Applicable functional checks such as tests, builds, or UI
     verification.

  Have the student select one behavior change with a runnable focused test, or
  explain why their current change is passive documentation or otherwise has no
  meaningful RED. Ask them to name the exact observable effect their test would
  assert. The lesson is done when they can state their RED/GREEN evidence or a
  truthful exception and name the focused verification command they would run.
---

# Test-First and Verification

A test command is not proof that a change works. A green suite can be unrelated
to the behavior that changed, and a review can notice design problems without
executing the contract. ODD therefore treats verification as a sequence of
observable evidence: use test-first development when a runnable deterministic
behavior test has a clear expected outcome, then run proportionate checks for
the actual task.

The goal is not ritual. It is to make the expected behavior concrete before an
implementation makes it easy to rationalize the wrong result.

## When test-first applies

For a behavior change, apply test-first development by default when all of these
are true:

- a runnable deterministic test is applicable;
- the expected outcome is clear; and
- a behavioral RED would be meaningful.

The presence of a test framework—or even nearby tests—does not establish those
conditions. A passive documentation change does not need a synthetic failing
test. Nor does a non-testable change, an unavailable runner, or a case where no
meaningful RED exists. In those cases, state the specific exception and run
proportionate ordinary functional or structural verification instead. Do not
claim RED/GREEN evidence that was not observed.

This distinction protects both honesty and signal. A contrived test that fails
for an unrelated reason teaches nothing; pretending documentation had a RED is
worse than describing a structural check plainly.

## The RED → GREEN → triangulate → refactor loop

When applicable, use a small loop:

1. **RED:** add the smallest behavior-level test that expresses the requested
   observable effect. Run the focused command and observe it fail for the
   intended missing behavior.
2. **GREEN:** implement the minimum change that makes that test pass. Run it
   again and record the observed pass.
3. **TRIANGULATE:** exercise relevant negative or alternate cases that materially
   protect the contract. One happy path is often too weak when invalid input,
   another branch, or a boundary condition could regress.
4. **REFACTOR:** improve clarity only while focused tests remain green.

The word “observed” is crucial. Writing a test that should fail is not RED until
the runner reports the intended failure. Editing code that should satisfy it is
not GREEN until the runner reports a pass.

Assertions should target every observable effect required by the behavior. If a
change has a visible output, a stored result, an error condition, and an
interaction with a collaborator, test the effects that form its contract—not
only an internal variable that happens to change today. This makes refactoring
safer because tests describe what users or callers can actually observe.

## Focused checks first

Run the focused test while iterating. It gives quick feedback close to the
change. Then run the applicable broader suite at closure. This ordering helps
locate failures: a focused failure points directly at the behavior, while a
suite failure may reveal an integration seam or an unrelated environmental
problem.

For delegated work, the parent provides the exact authorized runner and commands
when known, plus the test-first policy and any exception rationale. The writer
runs required commands synchronously in the foreground and reports each as the
exact command with its observed result. A required command that fails is not
hidden by a clean summary. An exact pre-existing failure named by the task is
reported as evidence; another required failure leaves the task partial.

## Verification is broader than a test

Every task needs applicable functional checks. The details depend on what
changed: a unit or request test, a build or typecheck, a browser or UI check, or
a structural load check for content. A TODO checkbox does not trigger a review
cycle and does not prove the behavior.

Native code review is also not a substitute for functional verification. Review
examines the candidate change from an independent perspective; tests, builds,
and manual functional checks execute or inspect the contract. When native review
is enabled, its candidate is a work-unit commit or PR slice, never a checkbox or
the entire accumulated feature branch. The separate evidence types catch
different mistakes.

A parent also spot-checks a reported command before delivery. This avoids
building a conclusion solely on a handoff and helps reveal mismatched commands
or environmental assumptions.

## Risk changes who verifies

The verification rule is proportional. A normal low- or medium-risk change uses
writer self-verification and its applicable tests. A change touching a named
high-risk item gets both self-verification and one separate verifier run. The
trigger is the named high-risk category—data, security, existing contracts,
concurrency, delivery/environment, or lack of a regression test—not file count,
model choice, or task size.

Even an unavailable or failed native assessment does not prove the work is low
risk. Conversely, native tier information does not excuse the focused functional
checks. The Risk line from **Task Size and Risk** supplies a clear reason for
this route.

## Example: adding validation

Suppose a request requires rejecting an empty project name. Write a test that
submits the empty name and asserts the observable rejection. Run it and see the
expected failure. Implement only enough validation to make it pass. Then test a
valid name, and perhaps whitespace if that is part of the stated contract. Once
those checks are green, refactor duplicated setup without changing the asserted
behavior.

If the requested task is only to correct a lesson paragraph, the RED step has no
meaningful behavioral outcome. State that the exception is passive documentation
and run the course’s content-loading check instead.

## Common mistakes

- **Calling an unrun test RED.** Evidence must be observed.
- **Testing internals instead of effects.** Preserve behavior through refactors.
- **Stopping after GREEN.** Consider alternate cases that protect the contract.
- **Using review as a test replacement.** Both are necessary when applicable.
- **Inventing a runner.** Use the project’s authorized command or report the
  limitation.

## Try it

Pick one behavior you expect to change. State the observable effect in one
sentence and write the smallest assertion that would distinguish the old behavior
from the new one. Name the command that will show RED, then the same command
that will show GREEN. If you cannot make that distinction, identify the honest
exception and the structural or functional check that still gives evidence.
