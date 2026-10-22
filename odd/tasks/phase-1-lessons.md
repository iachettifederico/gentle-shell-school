# Phase 1 — file-backed lessons, lesson pages, llms.txt, lessons JSON API

Gentle Shell School: a course for gentle-shell in the style of opencode.school, built on the rails-starter-template.
Branch: `feat/phase-1-lessons`. Delivery strategy: `ask-on-risk` → `chain_strategy=feature-branch-chain` (user choice, L8). No git remote yet.

## Specs

- S1 — Lessons are files, not database rows: `content/lessons/*.md` with YAML frontmatter (`title`, `slug`, `description`, `order`, `quiz`, `agent_instructions`). Rails reads and renders them. Malformed lessons (missing fields, duplicate slug or order) fail loudly instead of being skipped.
- S2 — Lesson pages: the home page lists lessons in `order`; `/lessons/:slug` renders the lesson body as HTML; an unknown slug is a 404. Titles use sentence case.
- S3 — Lessons JSON API, mirroring opencode.school: `GET /api/lessons` (array, sorted by `order`) and `GET /api/lessons/:slug`, each lesson as `{order, slug, title, description, agentInstructions, content}`. Unknown slug → 404 `{"error":"Lesson not found"}`. `{origin}` in instructions and in the lesson body (`content`, and the HTML page) is replaced with the request origin. Lessons with `quiz: true` get the shared quiz boilerplate appended at serve time. CORS headers `Access-Control-Allow-Origin: *`, `GET, OPTIONS`.
- S4 — `GET /llms.txt` (plain text) tells an agent what the school is and how to use the API, with URLs built from the request origin, and points to `GET /api/openapi.json`, which describes the lessons endpoints.

Selected scope (user choice, verbatim): "Yes, phase 1 with SQLite" — "Generate the app here and build phase 1, tracked as an ODD feature with work-unit commits."

## Tasks

- [x] T0 — Generate app from rails-starter-template (SQLite). Route: inline. Commit: `8d189d8`.
- [x] T1 — Domain: `Course::Lesson`, `Course::LessonContent`, `Course::Catalog`, agent-instruction policy (quiz boilerplate, `{origin}`). S1, S3. Route: inline. Commit: `fb04490`.
- [x] T2 — Adapter + system: file lesson repository, `Course::LessonsSystem` facade, seed `welcome` lesson. S1. Route: inline. Commit: `fb04490`.
- [x] T3 — HTML: home lesson list, `/lessons/:slug`, Markdown rendering (commonmarker). S2. Route: inline. Commit: `138bc63`.
- [x] T4 — API: `/api/lessons`, `/api/lessons/:slug`, CORS, `/llms.txt`, `/api/openapi.json`. S3, S4. Route: inline. Commit: `4d1d1bf`.

Forecast: ~700 authored changed lines across T1–T4. Actual: ~1,160 (hook count, lock files excluded).

### Slices (feature-branch chain)

1. PR 1 — `fb04490` domain + file-backed lessons (T1, T2).
2. PR 2 — `138bc63` lesson pages + Markdown rendering (T3). Risk: item 5 (new dependency `commonmarker`), item 2 (HTML rendering of authored content).
3. PR 3 — `4d1d1bf` agent API, llms.txt, OpenAPI, README (T4). Risk: none beyond a public read-only CORS API serving lesson content only.

## Log

- L1 (user, verbatim): "I'd like to make a gentle-shell course in the style of https://github.com/agentschools/opencode.school"
- L2 (user): asked for a recommendation; proposed Rails with the template at /home/fedex/code/rails-templates/rails-starter-template.
- L3 (decision): Rails + template; lessons as files, DB only for students/progress. Phasing: 1) lessons + agent API, 2) enrollment + progress API, 3) curriculum.
- L4 (user, verbatim): "Yes, phase 1 with SQLite"
- L5 (env): template `.ruby-version` pins `ruby-4.0.6`; `~/myNixOS` flake now only exposes `ruby-4.0.7`, so the app's `.envrc` fails to evaluate. Commands run via `direnv exec <template-dir>` (cached 4.0.6 shell). Not changed — user's call.
- L6 (decision): `{origin}` is also resolved in lesson bodies (the welcome lesson tells students to paste `{origin}/llms.txt` into their agent). Added `Course::Lesson#body_for(origin:)`.
- L7 (evidence): T1+T2 RED observed (missing files → LoadError; `body_for` → NoMethodError), GREEN 27 examples, 0 failures.
- L8 (user, verbatim choice): "Feature/tracker branch chain (recommended)".
- L9 (evidence): T3 RED 6 failures → GREEN; T4 RED 6 failures → GREEN. Full suite 40 examples, 0 failures; rubocop 62 files, no offenses; `bundle exec brakeman --exit-on-warn` 0 warnings. Server smoke test: /up 200, / 200, /lessons/welcome 200 with origin resolved, /lessons/nope 404, /llms.txt, /api/lessons, /api/lessons/nope 404 + CORS, OPTIONS 204, /api/openapi.json servers = request origin.
- L10 (verify): independent gentle-ai-verify on T3+T4 — S2, S3, S4 pass; XSS probe (`<img onerror>`, `javascript:` links) escaped/stripped; no blocking findings. Lockfile resolves only x86_64-linux (other platforms unverified).
- L11 (env, open): `bin/brakeman` exits 5 because it forces `--ensure-latest` and brakeman 8.1.0 is out, so `bin/ci` fails on any branch until brakeman is bumped. Not changed — user's call.
