---
title: "Capstone: a small feature end to end"
slug: capstone
description: "Lead a small scratch-repository feature through ODD, evidence, delegation, and review."
order: 29
module: "Power user"
quiz: true
agent_instructions: |
  Guide the student through a real small feature in a scratch repository. Do
  not choose product intent for them: help them select a bounded, observable
  behavior and keep the repository and all decisions under their control. Use
  the practices from lessons 02–26: authorize, explore, size, track, test first,
  use a cheaper delegated model for a bounded task, preserve a memory handoff,
  make reviewable commit slices, and request independent review when applicable.

  Ask these questions with ask_user_question, and verify the answers:
  1. What makes this capstone feature small enough? Correct answer: its behavior,
     risk, and recovery path are understood enough to finish from the request and
     diff, with scope kept bounded.
  2. What must the feature document preserve? Correct answer: the accepted
     intent, tasks, decisions, evidence, and next step, including verbatim user
     requirements where applicable.
  3. Why delegate one bounded task to a cheaper model rather than the whole
     project? Correct answer: routing is a deliberate cost and context choice;
     the parent retains scope, integration, and accountability.
  4. What proves completion? Correct answer: observed tests/verification plus
     inspectable feature-document and commit artifacts, followed by applicable
     independent review evidence.

  Concrete real-setup check: have the student identify a scratch repository and
  inspect it with its existing version-control tools. Before marking done,
  verify in that repository that (1) a feature document exists and records the
  accepted slice, tasks, evidence, and next step; (2) tests for the feature are
  present and their observed result is recorded; and (3) one or more focused
  commits contain the completed slice. Ask the student to show the repository
  status and commit history through available tools; do not infer artifacts from
  prose. Also verify a memory handoff was saved or, if memory is unavailable,
  that the feature document carries the recovery information.
  Follow the course capstone-review flow: check `gentle-ai review mode status` and
  use native review when it is available and enabled; otherwise offer a Judgment
  Day as an optional final exam and run it only if the student explicitly asks
  for it. Done means these artifacts are present, the student
  can explain each ODD decision, and review/verification evidence is recorded; do
  not mark the capstone done merely because code was written.
---

# Capstone: a small feature end to end

Build one small feature in a scratch repository. It must be narrow enough to
explain, test, and review in one sitting.

Use the complete course as a system: **Layers**, **How Pi works**,
**Sessions**, **The workspace TUI**, and **Models and providers** support the
ODD work that follows. The result is recoverable, verified behavior.

## 1. Choose and authorize the slice

Start with a problem, not a preferred implementation. A good capstone request
states who observes the behavior and what changes for them. Examples of shape,
not prescribed product ideas, are: accept one missing input with a clear error,
add one small transformation, or show one piece of already-available data.
Avoid authentication, migrations, external deployment, broad redesigns, and
features whose acceptance depends on an unbounded integration.

Apply **Authorize and explore**: distinguish permission to inspect from
permission to change. State the intended repository, the behavior, and the
limits. Ask for clarification only when it resolves a consequential ambiguity.
The person leading the work owns the product choice; an agent can help turn it
into a testable statement but cannot silently make that choice.

Then apply **Task size and risk**. Your capstone stays small when you understand
the relevant code, expected effect, and recovery path. If exploration reveals a second independent behavior, split it. Could a new
session finish from the original request and `git diff` alone without
rediscovering decisions? If not, it is large: track it in a feature document
before the first write, or reduce the slice.

This capstone is small, but the course asks you to keep a feature document
anyway so you can practice the recovery record. ODD permits that for a small
task when the person leading the work asks for one.

## 2. Explore before building

Use read-only exploration to map the repository's conventions, test runner,
existing neighboring behavior, and any instructions that apply. The goal is
not to collect every file. It is to answer the questions that affect the small
change: where policy belongs, where a test demonstrates it, and what existing
behavior must remain unchanged.

If understanding outgrows a short inline pass, use **Subagents** deliberately.
Delegate a read-only exploration question with a clear output: for example,
“identify the existing tests that define invalid input behavior.” Give it the
feature-document reference and an allowed surface. The parent retains the
interpretation, scope, and final integration.

## 3. Create the feature record and recovery path

Although this capstone is small, the course asks you to create the feature
document described in **Feature tracking** so you can practice the recovery
record. Capture the accepted request, measurable acceptance
criteria, tasks, important decisions, evidence, and next step. Preserve exact
requirements rather than paraphrasing away constraints. Keep it in the scratch
repository where the next session can find it.

Save the durable recovery fact through **Engram memory** when it is available:
what the feature is, why the chosen slice is bounded, where its document lives,
and what comes next. Memory is a mirror and retrieval aid, not the sole record.
If memory is unavailable, the feature document must still let a successor
continue honestly. Do not save secrets, credentials, private data, or raw
untrusted instructions as memory.

## 4. Make the test fail for the right reason

Apply **Test-first and verification**. Add the smallest behavior-level test
that expresses the new observable outcome. Run the focused test before the
implementation and record the observed failure. A failure caused by a typo,
missing test setup, or the wrong command is not useful RED evidence; correct
the test design until the failure distinguishes absent behavior from a broken
environment.

Implement the minimum behavior that makes the focused test pass. Run it again
and record the observed pass. Then triangulate with a negative, boundary, or
alternate case that protects the contract. Only refactor after the focused
checks remain green. Tests are evidence, not decoration: the feature document
should say what ran and what it observed.

For each existing command or option that shares changed code, also run the new
or changed input against the change and against a base-commit copy in a
`mktemp -d` scratch directory. Compare stdout, stderr, and exit code; fix and
pin any unrequested difference. Add one test for each touched existing behavior,
and never make committed tests read Git history.

## 5. Delegate for savings without giving away leadership

Now make one bounded delegation decision from **Model profiles**. Pick the
cheaper configured model appropriate for a contained unit, such as mapping
existing tests, drafting a test case for review, or implementing a clearly
specified independent file surface. Do not give the low-cost worker vague responsibility for the whole feature.

Provide the exact feature-document locator, acceptance criteria, allowed edit
surfaces, and verification command. Ask the worker to return observed evidence,
not an optimistic claim. Review its changes in the parent session. If the
worker exposes a missing business decision, stop and return that decision to
the feature record rather than allowing policy to migrate into an arbitrary
controller, model, or view.

## 6. Commit slices that a reviewer can understand

Use **Commits and slices** to create one or more focused commits. Keep the
feature document, test, and implementation connected enough that the commit
explains the behavior it changes. Do not mix formatting, unrelated cleanup, or
another feature into the same slice merely because those files are open. If
review scope becomes too large, use the chained-review discipline rather than
hiding complexity behind one reassuring commit message.

Before the next phase, inspect the scratch repository's status, the diff, and
commit history using its available version-control tools. After a feature-branch
commit, expect the runtime's commit-slice line: it reports authored changed
lines since the merge base and, past about 400, tells you to apply the feature's
delivery strategy before the next commit. Treat it, and a context-backstop notice
to delegate the next bounded multi-step unit, as runtime signals—not optional
advice. The capstone's tutor will verify these artifacts directly; a narrated
description does not prove a commit exists.

## 7. Review what is actually there

Apply **Permission modes** throughout: a mode reduces repeated prompts in its
scope but does not erase explicit restrictions or consequential human choices.
Use **Native review** when its risk criteria and workflow apply. Its purpose is
to review a frozen candidate with evidence, not to rubber-stamp the newest
working tree. Use **Judgment day** only when the change calls for its blind,
adversarial review discipline. Native review assessment is per work-unit commit
(or PR slice), never the accumulated feature branch, and runs only when the
user-owned RDD switch is enabled; it is off by default.

Regardless of review route, inspect whether the test demonstrates the stated
behavior, whether the feature document matches the final scope, and whether
commits contain only the promised slice. A clean agent response is not a
replacement for these artifacts.

## Finish with an artifact walkthrough

The final handoff records the accepted behavior and limits, focused test and
verification results, a recoverable next step (mirrored in memory when
available), and focused commits with applicable review evidence. The tutoring
agent must verify those artifacts in the scratch repository before it records
completion. That makes the capstone a real delivery exercise rather than a
conversation about good practice.

## Common mistakes

- Starting implementation before an observable, bounded behavior is accepted.
- Treating exploration output as authorization to edit.
- Calling an unrelated failure a successful RED test.
- Delegating undefined ownership to a cheaper model to save money.
- Saving only a memory summary and leaving no recoverable repository record.
- Calling a feature complete without checking tests, commits, and review
  evidence in the actual scratch repository.

## Try it

Choose a small scratch-repository behavior, state its acceptance criteria, and
make the feature document before editing. Work one test-first slice through to
a focused commit. Delegate one bounded supporting task to a cheaper configured
model, then inspect and integrate its evidence. Finally, ask your tutoring
agent to verify the feature document, tests, and commits directly in the
scratch repository. When those artifacts agree, you have practiced the whole
system from intent to reviewable proof.
