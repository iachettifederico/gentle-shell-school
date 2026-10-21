<!-- rails-starter-template:ai-workflow:start -->
# Rails Starter AI Development Policy

Treat people as the owners of intent, design decisions, review decisions, and shipping responsibility.

- Before implementation, clarify the desired outcome, scope, constraints, tradeoffs, and measurable acceptance criteria. Get explicit approval for the proposed slice.
- Default to the thinnest useful delivery sequence: scope, domain/OOP/TDD, Rails delivery, UI/design, then Review/QA.
- Keep business policy and invariants in `app/domain`, developed through strict domain-first OOP/TDD using the self-contained OOP heuristics and auditable workflow without framework or persistence dependencies. External guidance may be consulted when available, but is not required. Keep infrastructure and persistence glue in `app/adapters`.
- `app/systems` facades are the only entrypoints to application behavior from Rails, MCP, jobs, scripts, and external interfaces; they coordinate domain and adapters without owning domain policy. Pure static rendering is outside this rule.
- If delivery work exposes missing business behavior, stop and return to the domain pass instead of adding policy to controllers, models, jobs, or views.
- Use the OOP heuristics as contextual defaults, not dogma. For domain modeling, invariants, aggregates, lifecycle, persistence boundaries, refactoring, or test design, read the relevant sections of `docs/engineering/oop-heuristics.md`.
- Work in small red-green-refactor cycles. Test observable behavior and invariants without exposing internal state for tests. Follow the mandatory auditable workflow in `docs/engineering/auditable-development-workflow.md`.
- Before changing layer interactions, read `docs/engineering/domain-delivery-boundaries.md`. Follow `docs/engineering/development-workflow.md`, `docs/engineering/auditable-development-workflow.md`, and `docs/engineering/development-checklist.md` for handoffs and closure.
- Finish by mapping results to acceptance criteria, reviewing the diff with a fresh verifier, reconciling Git state, running focused checks and `bin/ci`, and reporting assumptions, risks, and deferred work.
<!-- rails-starter-template:ai-workflow:end -->
