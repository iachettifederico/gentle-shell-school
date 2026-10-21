# OOP/OOD/TDD Heuristics

## How To Use This Catalog

These heuristics are defaults for reasoning, not universal laws. Select the guidance relevant to the current uncertainty, state important tradeoffs, make the smallest reversible move, and verify it with executable behavior.

Identifiers `H01` through `H60` preserve the complete approved, de-duplicated ledger. The `E` items are refinements made explicit in individual episode notes.

## 1. Design Stance And Learning

- **H01 - Use heuristics as defaults, not dogma.** Context, language, team fluency, and observed change pressure decide how a heuristic applies.
- **H02 - Treat source code as the real design artifact.** Diagrams and prose support understanding, but executable behavior is authoritative.
- **H03 - Model the business first and defer interface/framework concerns.** Assume "perfect technology" while discovering policy: focus on what the system does before persistence, transport, UI, or deployment mechanics.
- **H22 - Preserve logical architecture first.** Physical distribution is a later deployment choice and should not distort object boundaries prematurely.
- **H28 - Treat TDD as an iterative learning loop, not ceremony.** Use feedback to discover responsibilities and revise assumptions.
- **H42 - Evaluate architecture by change impact, not initial delivery speed alone.** Track touched classes, changed collaborations, test churn, and the width of each step.
- **H43 - Choose the TDD entry point by uncertainty.** Domain uncertainty suggests model-first work; integration uncertainty suggests an outside-in tracer bullet.
- **H44 - Use tracer-bullet end-to-end slices early, then move inward.** Prove uncertain integration paths, then recover faster focused loops.
- **H54 - Treat storage technology as an architectural leverage decision, not a default habit.** Select it from behavior, consistency, recovery, and operational needs.

## 2. Construction, Validity, And Lifecycle

- **H04 - Create only valid objects from the start.** Enforce invariants at construction so illegal intermediate states cannot escape.
- **H05 - Fail fast on invalid domain state.** Use explicit assertions or exceptions with useful contract information.
- **H06 - Keep one canonical creation path.** Route alternate constructors and convenience factories through the path that guarantees validity.
- **H07 - Model lifecycle states explicitly.** Prefer state-specific objects or protocols over null-filled, partially initialized objects.
- **H08 - Do not use null as implicit domain state.** Translate nullable external input at boundaries.
- **E01 - Make creation dependencies explicit where creation happens.** A factory or creator should receive the collaborators required to produce a usable object rather than hiding global lookup.
- **E02 - Move partial construction to a staging object.** When input arrives over time, keep the domain object complete and use a builder, form, or staging object named in domain language.
- **E03 - Treat framework construction requirements as boundary constraints.** If an ORM requires an empty constructor, restrict it where possible and keep the canonical domain creation path explicit.

## 3. Encapsulation, Behavior, Identity, And Naming

- **H09 - Put behavior inside the model rather than passing IDs or DTO-shaped data carriers around.** Collaborate with objects that can answer domain messages.
- **H10 - Treat IDs as boundary and persistence concerns.** Do not let external addressing become the default mechanics of core object identity.
- **H11 - Do not break encapsulation in production code or tests.** Ask intention-revealing questions instead of exposing raw state for assertions.
- **H17 - Separate domain entities from access/authentication identities when responsibilities diverge.** Similar attributes do not imply one object or lifecycle.
- **H18 - Make boundary objects protect consistency.** Do not leak mutable internals or collections callers can alter around invariant owners.
- **H26 - Name abstractions and arguments by domain role and intention.** Avoid implementation, framework, or pattern jargon when it hides meaning.
- **H27 - Design callback and closure APIs for the host language and team.** Preserve clear roles rather than imitating another language mechanically.
- **H47 - Reify oversized methods as method objects when that unlocks decomposition.** Use the object to name intermediate state and enable smaller refactorings.
- **E04 - Replace primitive obsession with domain values.** Strings and numbers that carry rules, units, or identity deserve behavior and validation.
- **E05 - Prefer positive predicate names.** Positive questions compose more clearly and avoid double-negative control flow.
- **E06 - Distinguish object identity from external addressing.** ORM keys, REST identifiers, and in-memory identity solve different problems.

## 4. Collections, Aggregates, And Mutation

- **H12 - Model collections and aggregates as first-class objects when membership has rules.** A raw list cannot own cross-member behavior.
- **H13 - Enforce set-level invariants inside the owning aggregate.** Route additions, removals, and updates through it.
- **H14 - Prefer atomic, mediated update flows for mutable entities in shared constraints.** Avoid setter sequences that expose inconsistent intermediate state.

Database uniqueness and foreign-key constraints remain valuable safety nets, especially under concurrency, but they do not replace intention-revealing model rules.

## 5. Absence, Validation, And Failure Contracts

- **H15 - Centralize validation rules in the model.** Delivery/UI validation may mirror the same rule source for feedback but cannot redefine truth.
- **H16 - Skip cascading validations after prerequisites fail.** Report useful errors rather than noise caused by invalid earlier state.
- **H23 - Map expected domain failures to explicit boundary/API errors.** Do not expose technical crashes as business outcomes.
- **H55 - Treat exceptions as contract-break signals.** They communicate failed preconditions, postconditions, or invariants rather than generic noise.
- **H56 - Raise low and handle high.** Detect a violation where it occurs; decide recovery where business context exists.
- **H57 - Prefer explicit precondition checks in modern systems.** They improve diagnosability and avoid dependence on incidental runtime failures.
- **H58 - Avoid return-code error plumbing across collaborators.** Keep failure semantics distinct from normal return flow.
- **H59 - Add exception subclasses only when handling behavior differs.** Type hierarchies without behavioral purpose add ceremony.
- **H60 - Design errors for platform limits and tooling.** Account for closed/open models and preserve useful runtime context.
- **E07 - A failed command must preserve invariants.** Exception tests should prove the trigger, failure identity, message when relevant, and absence of partial mutation.

### Optional Versus Null Object

Choose from semantics rather than ideology:

- Use an Optional/Maybe-style protocol when generic composition such as mapping, filtering, or fallback clearly expresses absence.
- Use a Null Object when absence has stable domain-specific behavior deserving its own object and messages.
- Use neither to hide a lifecycle state that should be modeled explicitly.

## 6. Boundaries, Adapters, And Logical Architecture

- **H19 - Keep interface adapters framework-agnostic.** Accept plain inputs and return application-owned response types.
- **H20 - Keep external interfaces thin.** Parse and serialize transport formats at the edge; keep the model free of JSON and HTTP concepts.
- **H21 - Inject environment dependencies.** Pass clocks, randomness, identity generation, and external gateways rather than calling globals.
- **H24 - Minimize translation and mapping hops.** Every extra representation increases change ripple and opportunities for drift.

Use `docs/engineering/domain-delivery-boundaries.md` for the concrete Rails layer contract.

## 7. TDD And Test Design

- **H29 - Start with the smallest failing test.** If it passes immediately, the slice may be duplicated or too broad.
- **H30 - Measure cycle friction.** Long time-to-write or time-to-green signals oversized steps, coupling, or unclear responsibility.
- **H31 - Implement only what current tests demand.** Refactor deliberately after green rather than speculating ahead.
- **H32 - Prefer functional, behavior-focused tests over implementation choreography.** Tests should survive internal collaboration changes.
- **H33 - Treat tests as first-class users of the model.** Add useful behavior for them; do not grant privileged access to raw state.
- **H34 - Keep tests isolated and structurally clear.** Use setup, exercise, verify and one functional case per test.
- **H35 - Verify tests fail for the intended reason.** Exercise boundaries and use mutation-style probes to detect weak assertions.
- **H36 - Keep test oracles independent enough to catch drift.** Do not compute expected rules from the same constants or algorithm under test.
- **H37 - Extract recurring assertion protocols into domain-specific helpers.** Name the behavior being verified, not test mechanics.
- **H38 - Test exceptions completely.** Verify trigger, failure path, identity/message where relevant, and invariant preservation.
- **H39 - Use integration tests to complement fast unit-level feedback.** Do not replace focused design feedback with only slow end-to-end coverage.
- **H40 - Keep dual execution modes when useful.** Run fast transient/simulated collaborators locally and persistent/real collaborators for integration confidence through configuration, not duplicated tests.
- **H41 - Require acceptance-level confirmation before declaring behavioral closure.** Unit green is necessary but not sufficient for the approved outcome.

TDD does not guarantee good design. Use test pain as coupling feedback, but continue evaluating responsibilities, naming, and change impact.

## 8. Duplication, Refactoring, And Migration

- **H25 - Treat stable repeated flow as a missing abstraction.** Extract the common algorithm and parameterize meaningful variation with blocks, lambdas, or strategies.
- **H45 - Use transitional compatibility APIs intentionally during migrations.** Mark them temporary and remove them explicitly after cutover.
- **H46 - Prefer automated, chained refactorings over large manual surgery.** Keep behavior green through reversible steps.

Duplication is contextual. Explicit duplication can accelerate discovery while behavior and names are uncertain. Extract once the repeated protocol is meaningful and stable; premature abstraction can couple unrelated cases.

## 9. Persistence, Transactions, And Concurrency

- **H48 - Persist behaviorally meaningful actions first when ORM mapping is premature.** Let behavior stabilize before object-relational mechanics dominate design.
- **H49 - Persist only state-changing commands and keep reads side-effect free.** Make effects and replay semantics explicit.
- **H50 - Persist enough intent and metadata for deterministic replay or recovery.** A log that cannot reconstruct decisions is not a recovery mechanism.
- **H51 - Place transaction orchestration high in the call stack.** Cover the complete use case while keeping domain behavior independent of transaction APIs.
- **H52 - Handle concurrency conflicts at commit boundaries.** Combine database constraints with bounded retries and observable failure.
- **H53 - Keep environment selection explicit and automatable.** Switch transient, persistent, or remote implementations through configuration rather than manual code toggles.

Business prechecks improve feedback but cannot eliminate races. Database constraints protect committed state; model rules explain the business invariant. Use both at their appropriate boundaries.

## Quick Pairing Questions

Before coding:

- What invariant or uncertainty should fail first?
- Which object should own this behavior?
- Is model-first or an end-to-end tracer the smaller learning step?

During coding:

- Is an object invalid or partial between messages?
- Is null hiding state, or does absence have an explicit protocol?
- Are data or framework types leaking across a boundary?
- Are tests checking behavior without coupling to choreography?
- Is this step small and reversible?

Before merging:

- Did failure preserve invariants?
- Is repeated flow stable enough to abstract?
- Are transaction and recovery decisions made where business context exists?
- Has acceptance behavior been confirmed?

## Provenance

This catalog is an English adaptation of the approved `Diseno a la Gorra - Heuristics Ledger` in `_heuristics.md`, cross-checked against the `Diseno a la Gorra - Pairing Playbook` in `_playbook.md` and these processed episode notes:

- `s01e01-que-es-disenar-y-como-hacer-que-un-diseno-nos-ensene.md`
- `s01e02-objetos-validos.md`
- `s01e03-modelar-los-conjuntos-de-objetos.md`
- `s01e04-no-usar-null.md`
- `s01e05-codigo-repetido-e-historia-de-los-closures.md`
- `s01e06-tdd-y-roles-de-clases.md`
- `s01e07-todo-lo-que-siempre-quisiste-saber-sobre-los-tests.md`
- `s01e08-buenos-aires-vs-london-vs-chicago.md`
- `s01e09-buenos-aires-vs-london-vs-chicago-parte-2.md`
- `s01e10-buenos-aires-vs-london-vs-chicago-parte-3.md`
- `s01e11-buenos-aires-vs-london-vs-chicago-parte-4.md`
- `s01e12-buenos-aires-vs-london-vs-chicago-parte-4b.md`
- `s01e13-buenos-aires-vs-london-vs-chicago-parte-5.md`
- `s01e14-buenos-aires-vs-london-vs-chicago-parte-6.md`
- `s01e15-buenos-aires-vs-london-vs-chicago-parte-7.md`
- `s01e17-excepciones-y-adios.md`

The source ledger is de-duplicated; episode refinements are labeled `E01` through `E07` here. This generated document carries the guidance itself and requires no access to the original corpus.
