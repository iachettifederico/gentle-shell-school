# Phase 5 — Agent feedback as GitHub issues

Let the tutoring agent report course problems as GitHub issues, the way Gentle AI relays provider defects. The repository becomes public.
Branch `feat/phase-5-feedback` (stacked on `feat/phase-4-finish-site`). Repo: `iachettifederico/gentle-shell-school`.

## Specs

- S1 — "we need to add a way for the agent who's going through the course can send feedback (github issues). If we need to make the repo public that's fine"
- S2 — "i like the way that gentle ai handles it. I think public repo and the user chooses how to connect with github if they dont have default way already"

### Design (parent decision from L3 evidence)

- D1 — Trigger: the agent (or the student) finds a wrong or outdated fact, a broken setup check, a confusing explanation, a typo, or a bug in the site/API. Consent first with ask_user_question, single choice, in this order: "Report it and continue", "Continue without reporting", "Stop here". No report without the first choice.
- D2 — Duplicate search first: `gh issue list --repo iachettifederico/gentle-shell-school --state all --search "<query>"`; if an equivalent exists, offer to add one evidence-only comment instead.
- D3 — Transport: if `gh auth status` shows a login for github.com, create with `gh issue create --repo iachettifederico/gentle-shell-school --title ... --body-file ... --label course-feedback --label agent-report`, then read it back with `gh issue view`. If not, the student chooses how to connect (ask_user_question): "Log in with gh now" (`gh auth login`, then file), "Open a prefilled link in my browser" (the agent builds `https://github.com/iachettifederico/gentle-shell-school/issues/new?template=course-feedback.yml&title=...&lesson=...&kind=...&what-happened=...&expected=...&environment=...` with URL-encoded values and the student submits it), "Skip reporting".
- D4 — Content: title `[Course feedback] <lesson-slug>: <short summary>` (`site` instead of a slug for site/API problems). Body starts with "Filed by a tutoring agent with the student's explicit consent. Observed evidence only." then the issue-form sections in order: Lesson, Kind, What happened, Expected, Environment (gentle-shell version, model). Privacy: never include the student ID, absolute paths, usernames, hostnames, credentials, environment values, private project names, or source contents.
- D5 — Repository: issue form `.github/ISSUE_TEMPLATE/course-feedback.yml` (fields with ids `lesson`, `kind` dropdown, `what-happened`, `expected`, `environment`; labels course-feedback), `config.yml` linking the course site; labels `course-feedback` and `agent-report` created on GitHub by the parent.
- D6 — Surfaces: `/llms.txt` "Reporting problems" section (D1–D4 with exact commands); `/api/instructions/:id` mentions it; OpenAPI `info.description` links the issues page; the website footer and each lesson page get a "Report a problem" link to the prefilled issue form (lesson slug filled); the welcome lesson's agent_instructions and body mention that feedback is welcome; README documents it. Repo URL lives in one config value.
- D7 — Before going public: scrub absolute home paths from tracked files (e.g. `/home/<user>/...` → `~/...`), check tracked files for secrets; git history is not rewritten.

## Tasks

- [x] T1 — D5 issue form + config, D6 surfaces with request specs. Route: gentle-ai-worker. Commit: `d6bafe3`.
- [x] T2 — D7 scrub + secrets check, labels on GitHub, make the repo public, verify the issue form renders and the prefilled link works. Route: parent (outward-facing). Commit: scrub in the commit after `d6bafe3`; GitHub changes are not commits.

## Conventions for workers

- Same as `odd/tasks/phase-4-finish-site.md` "Conventions for workers" (run via `/tmp/gss-run`, layers, cops, test-first for server behavior, no new gems, do not commit).
- English. Exact strings in D1/D3/D4 are copied verbatim into llms.txt.

## Log

- L1 (user, verbatim): "we need to add a way for the agent who's going through the course can send feedback (github issues). If we need to make the repo public that's fine"
- L2 (user, verbatim): "i like the way that gentle ai handles it. I think public repo and the user chooses how to connect with github if they dont have default way already"
- L3 (evidence): Gentle Pi `assets/orchestrator-prompts.md` "Gentle AI Provider Defect Handoff" — narrow trigger, blocking 3-choice consent ("Report the Gentle AI defect and continue", "Continue without reporting", "Stop here"), definitive duplicate lookup, `gh issue create` + read-back, privacy scan (no argv, absolute paths, private project names, usernames, hostnames, credentials, diffs, source, env values). Real example gentle-ai #5593: title "[Automated provider defect] ...", body "## Automated provider-defect report / Filed by an agent with explicit operator consent. Observed evidence only...", sections Environment / Observed evidence. Gentle AI documents no fallback without gh auth; S2 adds the student's choice of connection (D3).
- L4 (evidence T1): worker d6bafe3 — course-feedback.yml form (ids lesson, kind, what-happened, expected, environment), config.x.course.feedback_repository, llms.txt "Reporting problems", instructions pointer, OpenAPI description, footer + lesson "Report a problem" prefilled links, welcome lesson + README; RED→GREEN request specs, 79 examples, bin/ci passed. Parent removed the worker's placeholder contact link (https://gentle-shell-school.example) from config.yml since the production URL is unknown.
- L5 (evidence T2): tracked-file scan found one absolute home path (phase-1 doc), scrubbed; deploy.yml IPs/passwords are template placeholders. Full-history scan: no tokens, keys, or secret files; one historical commit keeps that home path (history not rewritten, D7). Labels course-feedback and agent-report created; repository made public; anonymous GET of the repo page 200. Issue forms render only from the default branch, so the form and prefilled links go live when phases 4–5 reach main (user decision after morning testing).
