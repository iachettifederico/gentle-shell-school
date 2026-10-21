# Auditable Development Workflow

Build approved behavior with evidence that another person can inspect without reconstructing the work.

## Before Implementation

1. State the product outcome, thinnest scope, exclusions, constraints, tradeoffs, and measurable acceptance criteria.
2. Inventory the affected behaviors and invariants. For each, classify existing evidence as direct, indirect, weak, or missing.
3. Obtain approval for the domain contract before adding persistence or delivery code. A characterization test describes current behavior; it is not historical TDD evidence.
4. Start from a clean baseline and record the command and result.

## Behavior Evidence

Keep evidence distinct: process evidence records how the change was developed, acceptance evidence proves the approved outcome, and coverage evidence shows which behavior and invariant cases are direct, indirect, weak, or missing.

Use one functional case per test. Make setup, exercise, and verification obvious. Test black-box outcomes, complete failure contracts, and invariant preservation instead of exposing internal state.

For each changed behavior, keep a concise ledger:

| Step | Evidence to retain |
| --- | --- |
| RED | Exact focused command and its intended failing output |
| GREEN | Minimal behavior that makes that command pass |
| Refactor | Cleanup performed while the focused command remains green |
| Rerun | Focused command and final result after the change |

Do not manufacture a ledger after the fact. Record the evidence produced during the work and clearly label any pre-existing or characterization coverage.

## Delivery Sequence

1. Develop framework- and persistence-agnostic domain behavior first.
2. Add systems and adapters incrementally around the approved contract.
3. Route external behavior through `app/systems`; Rails, MCP tools, jobs, scripts, and other interfaces do not invoke domain behavior directly. Pure static rendering is an exception.
4. When behavior is user-facing, add an early browser-visible example before broad UI polish.
5. If delivery exposes missing policy, return to the domain contract and its evidence.

## Review And Closure

Use one writer and a fresh read-only verifier or auditor. The reviewer checks acceptance criteria, behavior and invariant coverage, boundaries, failure paths, and unnecessary scope.

Run focused checks while iterating and full CI before closure. Reconcile Git state: reviewed bytes, paths, and executable modes must match the intended diff; the worktree and index must contain only understood changes. Human review is required before committing or shipping.

## Related Guidance

- `docs/engineering/development-workflow.md` defines the delivery passes and approval gate.
- `docs/engineering/domain-delivery-boundaries.md` defines layer entrypoints and responsibilities.
- `docs/engineering/development-checklist.md` provides the executable closure checklist.
