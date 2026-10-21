# Human-First Development Workflow

## Purpose

People own intent, judgment, implementation decisions, review decisions, and shipping responsibility. AI agents help clarify and execute approved work; they do not turn a single request into an unreviewed design.

## Session Flow

1. Capture the desired user or business outcome in plain language.
2. Define the thinnest useful scope, explicit exclusions, constraints, tradeoffs, risks, and measurable acceptance criteria.
3. Check the layer contract in `docs/engineering/domain-delivery-boundaries.md`.
4. Inventory affected behavior and invariants, including direct, indirect, weak, and missing evidence.
5. Obtain explicit human approval for the scope, design, and domain contract before persistence or delivery implementation.
6. Implement the approved slice through the relevant passes using the mandatory `docs/engineering/auditable-development-workflow.md` evidence ledger.
7. Verify acceptance criteria, have a fresh read-only reviewer inspect the diff, reconcile Git bytes/paths/modes, run checks, and correct failures.
8. Record decisions, remaining risks, and deferred work when they will matter later.

Architecture indexes or code graphs may be used for orientation when the project provides them. They never replace repository source: verify exact behavior in the files before editing.

## Default Pass Order

### 1. Scope Pass

- State the problem and desired outcome.
- Produce functional and non-functional acceptance criteria.
- Identify assumptions, constraints, risks, and open questions.
- Split work into the smallest independently valuable slice.
- Do not make premature framework or implementation commitments.

### 2. Domain/OOP/TDD Pass

- Start business behavior in `app/domain` and tests in `spec/domain`.
- Use the self-contained OOP heuristics and auditable workflow for strict domain-first OOP/TDD; external guidance is optional.
- Identify objects, responsibilities, collaborators, invariants, lifecycle, and failure contracts.
- Decide persistence policy as part of domain behavior rather than as a controller or ORM convenience.
- Select relevant guidance from `docs/engineering/oop-heuristics.md`.
- Use a failing test, minimal passing behavior, then deliberate refactoring.
- Retain the focused RED command and failure, minimal GREEN, and focused rerun result for each changed behavior.

### 3. Rails Delivery Pass

- Implement routes, controllers, forms, jobs, and views around approved system facades and domain contracts.
- Keep request parsing, response mapping, sessions, and rendering in delivery code.
- Keep controllers thin and prefer Hotwire/Turbo before custom JavaScript when it fits the interaction.
- If a required domain contract is missing, return to the domain pass.

### 4. UI/Design Pass

- Implement the approved presentation without redefining business behavior.
- Verify mobile-first behavior, accessibility, responsive layout, focus states, labels, contrast, and interaction feedback.

UI discovery may precede Rails implementation only when a human explicitly approves it as a discovery exercise. Domain policy still cannot migrate into the UI.

### 5. Review/QA Pass

- Review against acceptance criteria and the domain/delivery boundary.
- Prioritize behavioral regressions, security, failure paths, and missing valuable tests.
- Run focused checks while iterating and `bin/ci` before closure.
- Reconcile the reviewed diff with the Git worktree and index, including intended paths and executable modes.
- Report each criterion as passed, partial, or missing.
- Identify blockers, risks, rollout concerns, and follow-up ownership.

No slice is complete until Review/QA is reconciled or its exceptions are explicitly accepted.

## Handoffs

Every pass should leave a short handoff containing:

- Decisions and why they were made.
- Assumptions and alternatives considered.
- Contracts added or changed.
- Checks run and their results.
- Risks, unresolved questions, and the next responsible pass.
- RED/GREEN/refactor/rerun evidence, or an explicit characterization-test label.

## Standard Commands

Use the commands that exist in the generated project:

```bash
bin/setup --skip-server
bin/rspec
bin/rubocop
bin/ci
```
