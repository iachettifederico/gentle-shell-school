# Domain And Rails Delivery Boundaries

## Layer Model

- `app/domain`: source of business truth, policy, invariants, and stable contracts.
- `app/adapters`: infrastructure and persistence implementations used through domain-facing contracts.
- `app/systems`: application/system coordination across domain capabilities and adapters.
- Rails delivery (`app/controllers`, `app/views`, `app/helpers`, forms, channels, and jobs as appropriate): translates external protocols into system-facade calls and results back into responses.

Dependencies point inward. Domain code must remain framework-agnostic and must not depend on Rails delivery, Active Record, request/session/view primitives, or transport formats.

## Domain Responsibilities

- Own business outcomes, authorization decisions, invariants, and lifecycle rules.
- Define intention-revealing commands, result objects, value objects, and failure contracts.
- Own policy for what changes state, what persists, and when persistence is required.
- Receive clocks, randomness, identity generation, and gateways as explicit collaborators.
- Return domain-owned results rather than HTTP statuses, JSON structures, or framework objects.

## Adapter Responsibilities

- Implement persistence, external services, clocks, queues, and other infrastructure contracts.
- Translate technical failures into the domain/application failure vocabulary at a deliberate boundary.
- Keep framework-specific mapping at the edge and avoid leaking mutable infrastructure state inward.
- Use database constraints as concurrency and consistency safety nets, not as a replacement for domain rules.

## System Responsibilities

- Coordinate use cases that span domain objects or adapters without absorbing domain policy.
- Provide the only application behavior entrypoints for Rails, MCP tools, jobs, scripts, and other external interfaces.
- Place transaction orchestration high enough to cover the complete state-changing operation.
- Keep read flows side-effect free and make command side effects explicit.
- Decide retries or recovery where business context exists; keep retries bounded and observable.

## Rails Delivery Responsibilities

- Parse and validate request shape, coerce input, manage sessions, and choose response status/rendering.
- Map validated input to system-facade calls and map their results to delivery responses.
- Configure concrete adapters for system facades.
- Keep templates focused on rendering explicit view data rather than discovering identity or policy.

## Hard Rules

1. Rails, MCP tools, jobs, scripts, and other external interfaces may call system facades only; pure static rendering is an exception. Domain code cannot call Rails primitives.
2. Active Record records and external IDs do not automatically define domain entities or identity.
3. Controllers, jobs, models, callbacks, helpers, and templates cannot decide domain-owned outcomes.
4. Do not infer authentication or authorization policy from session data inside templates.
5. Route aggregate membership and mutation through the aggregate that owns the invariant.
6. Map nullable or malformed external input at a boundary; do not make implicit `nil` a domain lifecycle state.
7. If delivery work reveals a missing rule, pause and implement the rule and its domain tests first.

## Forms And Views

Use Active Model form objects when Rails input needs delivery-level presence checks, coercion, normalization, or malformed-input feedback. Once input shape is valid, map it to domain values and commands. Business invariants remain in the domain and should not be independently redefined by form validations.

Prefer explicit locals and view/context objects over broad helpers. Views render already-decided outcomes; they do not query infrastructure or reconstruct policy.

## Boundary Review

Before merging, ask:

- Can the domain behavior run without Rails loaded, and do external callers enter through a system facade?
- Did a framework type, transport structure, or database identifier leak inward?
- Is any business branch implemented only in delivery code?
- Are transactions, retries, and failure mapping placed where enough context exists?
- Can callers mutate constrained state without going through its owner?
