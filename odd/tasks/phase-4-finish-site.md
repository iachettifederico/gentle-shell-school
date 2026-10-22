# Phase 4 — Finish the site

Turn the bare website around the finished curriculum into a complete, polished course site the user can test.
Branch `feat/phase-4-finish-site`. Writers run on openai-codex model profiles (context backstop reached in the parent).

## Specs

- S1 — "id like yu to finish the whole app,i'll test it tomorrow morning"
- S2 — "and when you finish, givit a coat of paint. Use the gentle ai site as inspiration and use the claude web design skill unless you dont know about it"

### Scope (parent decision, L2 — the user is unavailable until morning)

- D1 — Modules: lessons carry an optional `module` frontmatter key; the API exposes it; the home page groups lessons by module (syllabus order) with a per-module "N/M done" count when enrolled.
- D2 — Lesson page: module label, previous/next lesson links, completion state with "Mark complete" / "Mark not complete" buttons when enrolled (PUT with `source: "browser"` / DELETE `lessonSlug`, existing API), and a "Teach me this lesson" box with a copy button containing: `Read <origin>/llms.txt and teach me the "<title>" lesson (<slug>).` Home page: overall "N of M lessons complete" summary, a "Continue with: <next incomplete lesson>" link, and a copy button on the start prompt.
- D3 — Design and polish: consistent header/footer, readable typography and code blocks (Tailwind typography already installed), mobile layout, a styled 404 page for unknown lessons (status 404), per-page `<meta name="description">` and Open Graph title/description, remove the unused `hello_controller.js`.
- Out of scope: accounts/login, new API endpoints, lesson content changes beyond adding `module`, analytics.

## Tasks

- [x] T1 — D1 modules: domain `Lesson#module`, file adapter key, API `module` field + `config/openapi.yml`, `module:` in all 27 lesson files, home grouped by module. Route: gentle-ai-worker. Commit: `aaf6611`.
- [x] T2 — D2 lesson page + home progress UX (Stimulus, shared student ID). Route: gentle-ai-worker. Commit: `b563a8c`.
- [x] T3 — D3 + S2 coat of paint (Gentle AI site look, frontend-design skill), 404, meta, cleanup. Route: gentle-ai-worker + parent fixes. Commit: `08b7e19`, parent copy/favicon fix in the next commit.
- [x] T4 — Verify S1/D1–D3 in a real browser against a dev server, `bin/ci`. Route: gentle-ai-verify + parent. Commit: — (verification only).

## Conventions for workers

- Run commands through `/tmp/gss-run '<cmd>'` (Ruby 4.0.7, Rails main 8.2.0.alpha, Tailwind 4, importmap, Stimulus). Checks: `bin/rspec`, `bin/rubocop`, and `bin/ci` at the end of your task.
- Layers per `AGENTS.md` and `docs/engineering/domain-delivery-boundaries.md`: rules in `app/domain/course`, persistence/IO in `app/adapters`, controllers call only `app/systems/course/*_system.rb`. Custom cops: no public `attr_reader` in domain, ≤5 params, methods ≤10 lines, no view helper methods (use locals/view objects). Do not disable cops.
- Test-first for behavior (domain, adapter, API, controller status codes): observe RED, then GREEN. Request specs need `type: :request`; assert exact status and JSON. Pure styling needs no RED; say so.
- Module names, in syllabus order: `Getting started` (01), `Foundations` (02–07), `Organic Driven Development` (08–13), `Delegation` (14–16), `Memory and skills` (17–19), `Safety and review` (20–22), `Power user` (23–27). The syllabus table is in `odd/tasks/phase-3-curriculum.md`.
- UI copy in English. T1/T2 kept the existing palette; T3 replaces it with the S2 design direction (L4). No new gems or npm packages.
- Do not commit; the parent commits.

## Log

- L1 (user, verbatim): "whats next? id like yu to finish the whole app,i'll test it tomorrow morning"
- L2 (decision): the user is away until morning, so the parent scoped "finished" as D1–D3 from the current gaps (10-line stylesheet, 9-line lesson page, no navigation or per-lesson progress, ungrouped 27-lesson list) instead of stopping to ask. Merge/push stay the user's decision; the branch is left ready.
- L3 (user, verbatim): "and when you finish, givit a coat of paint. Use the gentle ai site as inspiration and use the claude web design skill unless you dont know about it"
- L4 (evidence for S2): Claude's web design skill = Anthropic `frontend-design` at ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/frontend-design/skills/frontend-design/SKILL.md. Gentle AI site = https://gentle-ai.gentlemanprogramming.com/ (gentle-ai repo homepage). Its CSS tokens: --color-bg #09090b, --color-bg-card #111113, --color-bg-code #18181c, --color-accent #ea1889, --color-accent-hover #ff6db0, --color-accent-subtle #ea188926, --color-border #ffffff12, --color-border-hover #ea188959, text #fafafa / #a1a1aa / #52525b; font Inter (400–800) + mono. Look (screenshot /tmp/gai-site/gentle-ai.png): dark, sparse, centered hero, huge bold white title with the accent word in magenta ("Gentle-AI"), pill badge with subtle magenta background, magenta pill primary button + dark ghost secondary, thin translucent borders, small muted nav, stat counters in magenta.
- L5 (evidence T1, T2): T1 aaf6611 — module key in domain/adapter/API/OpenAPI, all 27 lessons, grouped home; 72 examples, rubocop clean, bin/ci passed. T2 b563a8c — catalog neighbors, lesson page module/prev-next/completion buttons/teach-me copy box, home summary/continue/module counts/start prompt; 77 examples, bin/ci passed. JS behavior unverified until T4.
- L6 (evidence T3): worker 08b7e19 — Tailwind @theme palette from L4, dark hero/syllabus/lesson layout, prose-invert, branded 404 rendered with status 404 (RED→GREEN request spec), meta + OG tags (request-spec), public 404/422/500 styled; worker could not delete files. Parent review of screenshots: fixed inaccurate copy ("Learn the command line", "learn the shell", "self-paced shell course" → gentle-shell), doubled border on `pre code`, deleted unused hello_controller.js, added favicon links.
- L7 (evidence T4): gentle-ai-verify drove headless Chrome against a dev server on :3312 — scenarios A–H PASS (module order, enroll, 0/27 summary + continue, lesson mark complete/not complete, prev/next, exact teach-me text + clipboard, stale ID forgotten, 404 + home link, meta/OG, 375px no overflow). Console: only /favicon.ico (fixed) and the expected unknown-student 404. Test student removed. bin/ci passed after parent fixes; 77 examples.
- L8 (user, verbatim): "open port 300" — the user's own bin/dev server (puma :3000 + tailwindcss:watch) already serves this branch's working tree; confirmed 200 with the new design.
