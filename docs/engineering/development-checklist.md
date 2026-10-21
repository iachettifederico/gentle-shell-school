# Development Checklist

## Before Implementation

- [ ] State the desired outcome in one sentence.
- [ ] Define the thinnest useful scope and explicit exclusions.
- [ ] Capture constraints, tradeoffs, risks, and acceptance criteria.
- [ ] Read the relevant layer and OOP heuristic sections.
- [ ] Obtain explicit approval for the scope and design.
- [ ] Approve the domain contract before persistence or delivery work.
- [ ] Start from a clean baseline and record its command/result.

## Domain/OOP/TDD

- [ ] Identify the invariant or uncertainty that should fail first.
- [ ] Choose model-first or an end-to-end tracer based on that uncertainty.
- [ ] Keep objects valid from creation and collaborators explicit.
- [ ] Put behavior and set-level rules in the object that owns them.
- [ ] Run a small failing test, minimal implementation, then refactor on green.
- [ ] Test observable behavior, failure identity, and invariant preservation.
- [ ] Keep one functional case per test with explicit setup, exercise, and verification.
- [ ] Record the exact focused RED failure, minimal GREEN, refactor, and focused rerun for each changed behavior.
- [ ] Label characterization coverage as current-behavior evidence, not historical TDD.

## Delivery

- [ ] Keep Rails code as a thin adapter around system facades; do not call domain behavior directly except for pure static rendering.
- [ ] Keep parsing, coercion, sessions, status, and rendering at the edge.
- [ ] Return to the domain pass if delivery exposes missing policy.
- [ ] Verify routes and user-visible failure paths when they change.
- [ ] Check responsive behavior and accessibility for UI changes.
- [ ] Add a browser-visible example early for user-facing behavior.

## Review And Handoff

- [ ] Map each acceptance criterion to passed, partial, or missing evidence.
- [ ] Review the diff for boundary violations, regressions, and unnecessary scope.
- [ ] Run focused tests and `bin/ci`.
- [ ] Use a fresh read-only verifier or auditor after the writer completes the change.
- [ ] Reconcile reviewed Git bytes, paths, and executable modes with the worktree and index.
- [ ] Obtain human review before committing or shipping.
- [ ] Summarize changed files and checks with their results.
- [ ] Record assumptions, risks, and deferred follow-up work.
