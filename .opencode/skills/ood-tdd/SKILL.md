---
name: ood-tdd
description: Use for domain modeling, invariants, aggregates, object lifecycle, persistence boundaries, refactoring, exceptions, or TDD and test design in this Rails project.
---

# OOD/TDD Workflow

Use the project's engineering guidance as contextual heuristics, not dogma.

1. Confirm the approved outcome, scope, and acceptance criteria from `docs/engineering/development-workflow.md`.
2. Read `docs/engineering/domain-delivery-boundaries.md` when the work crosses domain, adapter, system, persistence, or Rails delivery layers.
3. Read only the relevant self-contained sections of `docs/engineering/oop-heuristics.md` and `docs/engineering/auditable-development-workflow.md` for the current design uncertainty; external guidance is optional.
4. State which heuristics govern this slice and any tension or exception that changes their application.
5. Route intentional behavior changes through `docs/engineering/auditable-development-workflow.md`; use characterization tests only to describe current behavior, not as historical TDD evidence.
6. Choose the TDD entry point by uncertainty: model-first for domain uncertainty, or an end-to-end tracer for integration uncertainty.
7. Execute a small failing test, minimal passing implementation, and deliberate refactoring on green; return the exact focused RED failure and GREEN rerun evidence.
8. Verify observable behavior, failure contracts, invariant preservation, layer boundaries, and acceptance criteria.
9. Report checks run, assumptions, risks, and deferred work.

Do not expose internal state solely for tests, put business policy in Rails delivery code, or turn semantic design judgments into mechanical rules.
