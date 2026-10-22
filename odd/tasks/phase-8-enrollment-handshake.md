# Phase 8 — Enrollment handshake between agent and browser

The agent prepares a pending enrollment and gives the student a link; the student voluntarily clicks "Enroll" in the browser, which creates the student and stores the ID in the browser; the agent picks up the same student ID. Agent and website are in sync from the first lesson.
Branch `feat/phase-8-enrollment-handshake` off `main`.

## Specs

- S1 — "the first instruction I see in the agent is to read localhost:3000. I think that when we start on the first lesson, the agent should point us to our almost enrolled student. and then we should see the enroll link which creates the student in the server. So we'll be synced from the get go."
- S2 — "yes, exactly. We could make enrollment automatic, but I prefer the student to know that they're enrolling to something and do it voluntarily"
- S3 (the flow the user confirmed, parent's restatement) — "the agent prepares an almost-enrolled student and gives you a link. You open it in the browser, it says \"Enroll\", you click, and that click creates the student on the server and saves it in your browser. From then on, the agent and the website share the same ID from the very first moment."

## Contract (parent decision)

- C1 `POST /api/enrollments` → `201` `{"code": "<code>", "enrollUrl": "<origin>/enroll/<code>", "status": "pending", "expiresAt": "<ISO 8601 UTC>"}`. The code is unguessable (SecureRandom.urlsafe_base64(24) or stronger). Expires 30 minutes after creation. No student is created. Request body optional.
- C2 `GET /api/enrollments/:code` → `200` `{"status": "pending", "expiresAt": ...}` while pending; `200` `{"status": "enrolled", "studentId": "<id>", "progress": <Progress>}` once claimed; unknown → `404` `{"error": "Enrollment not found"}`; expired and unclaimed → `410` `{"error": "Enrollment link expired"}`. A claimed enrollment stays readable after expiry. CORS and OPTIONS preflight like the other endpoints.
- C3 `GET /enroll/:code` (website): explains what enrolling means (an anonymous student ID, progress stored on the course server, no account, anyone with the ID can read/update that progress, "Forget this ID" exists) and shows an "Enroll" button (form POST with CSRF) and a "Not now" link home. If this browser already has a student ID in localStorage, warn that enrolling will switch this browser to the new ID. Unknown → styled 404 page; expired → styled 410 page with "Ask your agent for a new enrollment link". Already claimed → page says it is already used and links home (it never reveals the student ID).
- C4 `POST /enroll/:code`: atomically claims a pending, unexpired enrollment: creates the student through the existing enrollment system, records the student ID on the enrollment, marks it enrolled (single use: concurrent or repeated POSTs create at most one student). Responds with a confirmation page that stores the ID in `localStorage["studentId"]` (existing key) via Stimulus and links home and to the first lesson; tells the student to return to their agent. Expired → 410 page; already claimed → the "already used" page; no student created in either case.
- C5 Agent docs: `/llms.txt` "Progress" tells agents to start with the handshake (C1), give the student the `enrollUrl`, explain that enrolling is voluntary, and then check C2 (when the student says they enrolled, or every few seconds until `expiresAt`). If the student declines, teach without progress tracking. `POST /api/enroll` stays (the website's own Enroll button and old agents) but agents should prefer the handshake. Welcome lesson agent_instructions use the handshake. OpenAPI documents C1/C2; README lists them.

## Tasks

- [x] T1 — C1–C5: domain (pending enrollment with expiry and single-use claim rules), migration (new `pending_enrollments` table), adapter, system, API, website pages, Stimulus storing the ID, docs. Risk: item 1 (new table) and item 2 (unguessable codes, single use, no ID disclosure) → independent verify. Route: gentle-ai-worker + parent fixes. Commit: `d983b9d`, fixes `9aa75d5`.
- [x] T2 — Independent verification: contract, security (code entropy, single use under concurrent POSTs, no ID disclosure on the web page, CSRF), browser flow end to end, bin/ci. Route: gentle-ai-verify (two rounds). Commit: — (verification).

## Conventions for workers

- Same as `odd/tasks/phase-4-finish-site.md` "Conventions for workers" (run via `/tmp/gss-run`, layers, cops, test-first, no new gems, do not commit). Workers cannot delete files.
- Clock and random source injected into the domain, like `Course::StudentId`. Exact status codes and JSON bodies in request specs; rejected requests leave stored data unchanged.
- Keep the dark design classes; English copy.

## Log

- L1 (user, verbatim): S1. L2 (user, verbatim): S2.
- L3 (decision): parent proposed the pending-enrollment handshake (agent creates a pending code; the student's click creates the student; agent polls) over the simpler `/?student=<id>` link, because the student is only created after an explicit, voluntary action and the ID never travels in a URL. User confirmed.
- L4 (evidence T1): worker — PendingEnrollment domain (clock + random injected), pending_enrollments table, repository, EnrollmentSystem (claim re-checks status inside the transaction), API C1/C2 with CORS, /enroll/:code pages, Stimulus localStorage write, llms.txt/welcome/README/OpenAPI. Parent fixes: migration renamed 20260223120000 → 20261022120000 (collided with phase 6's evidence migration and had been silently skipped in the dev DB); db/schema.rb corrected by hand (the dev DB dump had leaked phase 6's `evidence` column).
- L5 (evidence T2 round 1, gentle-ai-verify): C1/C2, single use (sequential and concurrent curl; BEGIN immediate serializes claims), docs, migration PASS. FAIL: (a) tokenless POST without Sec-Fetch-Site accepted over HTTP (Rails main header-only strategy, actionpack request_forgery_protection.rb ~644); (b) Turbo kept the pending page after Enroll, so localStorage was never set; (c) plaintext codes in SQL/Parameters logs.
- L6 (fixes 9aa75d5, RED→GREEN): `protect_from_forgery using: :header_or_legacy_token, with: :exception` (token fallback, ~657); enroll form `data-turbo="false"`; codes stored as SHA-256 `code_digest`, `:code` filtered from parameters. Parent confirmed agent API calls stay tokenless (Api::BaseController < ActionController::API): POST /api/enroll 201, POST /api/enrollments 201, PUT/DELETE progress 200.
- L7 (evidence T2 round 2): all PASS — header-less and cross-site tokenless POSTs 422 with nothing created; Chrome flow: curl C1 → open link → Enroll → "Return to your agent", localStorage set, C2 enrolled with the same ID, home shows it; plaintext code only in request-line log entries; DB has only code_digest; 410 covered by specs (not exercised live). 104 examples. Residual: the request line still logs the path with the code (operator-only logs, single use, 30-minute expiry). Test students created during verification were deleted from the dev DB.
