# Phase 2 — anonymous enrollment and progress tracking

Students enroll anonymously, get a student ID, and their agent marks lessons complete through the API; the website shows progress. Mirrors opencode.school's `/api/enroll`, `/api/progress/{studentId}`, `/api/instructions/{studentId}`.
Branch: `feat/phase-2-progress` (from `feat/phase-1-lessons` @ `0bd2ea8`). Delivery: `feature-branch-chain` (same choice as phase 1, L8 there).

## Specs

- S1 — Identity: "Anonymous student ID (like opencode.school)" — "Random ID on enroll, no login. Whoever has the ID can read and update that progress." Format like opencode.school: `<adjective>-<noun>-<4 digits>` (e.g. `curious-hacker-2019`), validated by `/\A[a-z]+-[a-z]+-\d{4}\z/`. Generation retries on collision (up to 10 tries, then fails loudly).
- S2 — `POST /api/enroll` → `201` `{"studentId": "...", "progress": <Progress>}`. Request body optional.
- S3 — `GET /api/progress/:student_id` → `200` `<Progress>`. Invalid format → `400` `{"error":"Invalid student ID format"}`. Unknown student → `404` `{"error":"Student not found"}`.
- S4 — `PUT /api/progress/:student_id` with `{"lessonSlug": "...", "source": "agent"|"browser", "model": "..."}` marks the lesson complete and returns `200` `<Progress>`. `source` defaults to `"browser"` unless exactly `"agent"`; `model` optional (trimmed, blank → omitted). Idempotent: completing an already-completed lesson keeps the original completion entry. Errors (all `{"error": ...}`): invalid ID → `400` "Invalid student ID format"; unparseable JSON → `400` "Invalid JSON body"; missing/blank `lessonSlug` → `400` `Missing or invalid "lessonSlug" field`; unknown lesson → `400` `Unknown lesson slug: "<slug>"`; unknown student → `404` "Student not found". A rejected request leaves stored progress unchanged.
- S5 — `DELETE /api/progress/:student_id` with `{"lessonSlug": "..."}` marks that lesson incomplete; with `{"reset": true}` clears all completions but keeps the student. Returns `200` `<Progress>`. Neither field → `400` `Provide "lessonSlug" or "reset": true`; other errors as S4.
- S6 — `<Progress>` JSON: `{"completedLessons": [{"slug", "completedAt" (ISO 8601 UTC), "source", "model"? }], "createdAt", "updatedAt"}`; `completedLessons` sorted by `completedAt`. `updatedAt` changes on every successful PUT/DELETE.
- S7 — `GET /api/instructions/:student_id` → `200` `text/plain`: "My Gentle Shell School student ID is <id>", when to use it, and a pointer to `<origin>/llms.txt`. Errors as S3 (JSON).
- S8 — CORS on all new endpoints: `Access-Control-Allow-Origin: *`, methods listing what the endpoint supports plus `OPTIONS` (`POST, OPTIONS` for enroll; `GET, PUT, DELETE, OPTIONS` for progress; `GET, OPTIONS` for instructions); OPTIONS preflight → `204`.
- S9 — Website: home page has an "Enroll" button; the student ID is kept in the browser (`localStorage`), shown with a "Forget this ID" action; lesson list shows a checkmark on completed lessons (fetched from the progress API). Works without login.
- S10 — Agent docs: `/llms.txt` explains enrollment, the student ID, marking completion with `PUT` (with `source: "agent"` and the agent's `model`), redo/reset with `DELETE`, and the instructions URL; the "progress tracking is not available" line is removed. `config/openapi.yml` documents every new endpoint and schema. README lists the endpoints.

## Tasks

- [x] T1 — Domain: `Course::StudentId` (generate with an injected random source, `valid?`), `Course::StudentProgress` aggregate (complete idempotently, uncomplete, reset, clock injected), completion source policy. S1, S4, S5, S6. Route: gentle-ai-worker (context backstop). Commit: `961587f`.
- [x] T2 — Persistence + system: migration (`students`, `lesson_completions`, unique index on student+slug), Active Record models, progress repository adapter, `Course::ProgressSystem` (enroll with collision retry, find, complete/uncomplete/reset validating slugs against the lesson catalog, transactions). S1–S6. Risk: item 1 (new tables, deletes on reset) → own commit. Route: gentle-ai-worker. Commit: `301b1d0`.
- [x] T3 — API: enroll, progress GET/PUT/DELETE, instructions, CORS/preflight, OpenAPI, llms.txt, README. S2–S8, S10. Route: gentle-ai-worker. Commit: `3035707`.
- [x] T4 — Website: enroll button, localStorage ID, forget action, checkmarks via Stimulus. S9. Route: gentle-ai-worker. Commit: `416f717`.

Forecast: ~900 authored changed lines → 3–4 slices on the chain.

### Slices (feature-branch chain, continuing phase 1's three)

4. `0bd2ea8` build: Rails main configuration (from distribute). Risk: item 5.
5. `961587f` + `301b1d0` domain + persistence (T1, T2). Risk: item 1 (new tables, deletes) — independently verified (L6).
6. `3035707` progress API + docs (T3).
7. `416f717` website enrollment + checkmarks (T4).

## Conventions for workers

- Run every command through `/tmp/gss-run '<cmd>'` (direnv shell for this app: Ruby 4.0.7, Rails main 8.2.0.alpha). Checks: `bin/rspec`, `bin/rubocop`, and at closure `bin/ci`.
- Layers per `AGENTS.md` and `docs/engineering/domain-delivery-boundaries.md`: business rules in `app/domain/course` (no Rails, loadable with `spec_helper` + `require_relative`, see `spec/support/course_lessons.rb`); Active Record and persistence in `app/adapters`; `app/systems/course/*_system.rb` is the only entry point controllers call; controllers parse input and map results to HTTP. Phase 1 examples: `app/domain/course/lesson.rb`, `app/adapters/course/file_lesson_repository.rb`, `app/systems/course/lessons_system.rb`, `app/controllers/api/*`.
- Custom cops: no public `attr_reader` in domain (write explicit methods), ≤5 params, method length ≤10, no helper methods (use locals/view objects). Do not disable cops.
- Test-first: observe RED before implementing each rule, then GREEN. Request specs need `type: :request`; lesson fixtures via `spec/support/lesson_fixtures.rb`. Assert exact status, exact JSON body, and that rejected requests leave stored data unchanged.
- Do not commit; the parent commits.

## Log

- L1 (user, verbatim): "I see that the server is started, but we can't track progress yet, right?"
- L2 (user choice, verbatim): "Anonymous student ID (like opencode.school)" — "Random ID on enroll, no login. Whoever has the ID can read and update that progress. Simplest, and fits a free public course."
- L3 (user choice, verbatim): "Yes: commit on feat/phase-1-lessons, then phase 2" — "...then branch feat/phase-2-progress from it and build progress tracking as a tracked ODD feature."
- L4 (decision): mirror opencode.school's contract (PUT to complete, DELETE to undo/reset, error strings) minus exercises, device IDs and student profiles (profile belongs with a future interview lesson).
- L5 (evidence T1+T2): worker RED (missing constants, missing persisted completions) → GREEN; parent review moved ActiveRecord errors out of ProgressSystem (adapter raises Course::StudentIdTaken, system raises Course::EnrollmentFailed "Could not generate a unique student ID after 10 attempts"; RED observed for the exhaustion spec). 59 examples, 0 failures; rubocop clean.
- L6 (verify T1+T2): S1, S4, S5 pass at domain/system layer. SQLite transactions are IMMEDIATE by default in this Rails (adapter default), two-thread test kept both updates. S6 clarification: `updatedAt` is set to the operation's time (real clock, µs precision); equal-timestamp collisions are accepted, no forced bump. Unchanged-rows-on-rejection for invalid/unknown students is asserted at the HTTP layer in T3.
- L7 (evidence T3): worker RED 9+2 failures → GREEN; 68 examples, rubocop clean, bin/ci passed. Parent smoke test on a dev server (separate pid file; user's :3000 server untouched): enroll, PUT agent+trimmed model, idempotent PUT kept completedAt, all S3–S5 error strings/statuses exact, DELETE lesson/reset, instructions text, per-endpoint preflight methods (S8), stale llms line removed. Test student deleted afterwards.
- L8 (evidence T4): worker RED (missing data-controller) → GREEN, 69 examples, rubocop clean, bin/ci passed; no system-spec browser on PATH. Parent drove Chrome for Testing 148 (Playwright cache) over CDP with a throwaway /tmp script against a dev server: fresh → Enroll visible; enroll → ID + instructions link shown and stored; PUT welcome → reload shows ✓ welcome; Forget → not enrolled, storage cleared; stale ID lucky-wizard-0000 → forgotten. No JS errors. Test student deleted.
