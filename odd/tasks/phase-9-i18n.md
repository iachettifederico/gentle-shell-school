# Phase 9 — Course in English, neutral Spanish, and Argentinian Spanish

Offer the website and lessons in `en`, `es` (neutral Spanish), and `es-AR` (Rioplatense, voseo). Agent-facing text stays in English; the agent teaches in the student's chosen language.
Branch `feat/phase-9-i18n` off `main`.

## Specs

- S1 — "we should make the course available in english, in neutral spanish and Argentinian spanish"
- S2 — user choice: "Website + lessons; agent instructions stay in English (recommended)" — "UI, lessons and labs in en/es/es-AR; llms.txt, agent_instructions and the skill in English, and the agent teaches in the student's language"

## Contract (parent decisions)

- C1 Locales: `en` (default), `es`, `es-AR`. Fallback for missing translations: `es-AR` → `es` → `en`; `es` → `en`. Language names in the switcher: "English", "Español", "Español (Argentina)".
- C2 URLs: English at the root (`/`, `/lessons/:slug`, `/enroll/:code`); Spanish under `/es/...` and `/es-AR/...` with the same slugs. Unknown locale prefix → 404. The header has a language switcher linking to the same page in the other locales. The URL is the language: no cookie and no automatic redirect (amended in L4). `<html lang>` matches the locale; `<link rel="alternate" hreflang>` for the three versions. Progress is shared across locales (same slugs, same student ID). `/llms.txt`, `/api/*`, and `/enroll` behavior stay locale-independent except as below.
- C3 Content layout: English files stay where they are and remain the source of truth for `order`, `quiz`, `module` key, and `agent_instructions`. Translations live in `content/lessons/<locale>/NN-slug.md` (same filename as the English file) with frontmatter keys exactly `title`, `description`, `module` (translated module name) and the translated Markdown body; nothing else. Demo course: `content/demo/lessons/<locale>/...`, same rule. Labs: `content/labs/<slug>/i18n/<locale>.yml` with `title` and `brief` only (starter files, check, rubric stay English). A missing translation falls back per C1, file by file.
- C4 API: `GET /api/lessons`, `/api/lessons/:slug`, `/api/labs`, `/api/labs/:slug` accept `?locale=en|es|es-AR` (invalid → `400` `{"error": "Unsupported locale: \"<value>\""}`); responses include `"locale"` (the locale actually served for that item after fallback). `agentInstructions` is always English.
- C5 Agent docs (English): `/llms.txt` gets a "Language" section: at the start, ask the student (ask_user_question) which language they want — English, Spanish (neutral), Spanish (Argentina) — fetch lessons with `?locale=`, and teach, quiz, and give feedback in that language; for `es-AR` use Rioplatense Spanish with voseo; for `es` use neutral Latin American Spanish with "tú"; keep commands, code, file paths, and tool names untranslated. The skill and agent_instructions stay English.
- C6 Translation rules: `es` = neutral Latin American Spanish with "tú" (no voseo, no "vosotros", no regional slang); `es-AR` = natural Rioplatense Spanish with voseo ("vos tenés", "abrí", "fijate"), warm but not slangy. Never translate commands, code, flags, file paths, URLs, tool names, product names (gentle-shell, Pi, Engram, Gentle AI, Judgment Day, ODD and its terms may be explained but the term itself stays), or `{origin}` placeholders. Keep Markdown structure, headings count, code blocks, and lists identical.

## Tasks

- [x] T1 — C1–C5 infrastructure: I18n config and fallbacks, locale routes + switcher + cookie + hreflang, UI strings in `config/locales/{en,es,es-AR}.yml` (translate all UI copy per C6), localized lesson/lab repositories with fallback, API `?locale=`, llms.txt Language section, specs. Route: gentle-ai-worker (3 rounds). Commit: `2604b83`.
- [x] T2 — `es` translations: lessons 01–15. Route: gentle-ai-worker (parallel batches of 3 lessons). Commit: `aec5d0c`.
- [x] T3 — `es` translations: lessons 16–29, demo lessons, lab i18n files. Route: gentle-ai-worker (parallel batches of 3 lessons). Commit: `aec5d0c`.
- [x] T4 — `es-AR` translations: lessons 01–15. Route: gentle-ai-worker (parallel batches of 3 lessons). Commit: `aec5d0c`.
- [x] T5 — `es-AR` translations: lessons 16–29, demo lessons, lab i18n files. Route: gentle-ai-worker (parallel batches of 3 lessons). Commit: `aec5d0c`.
- [x] T6 — Verify: structure parity (headings, code blocks identical), untranslated commands, register (tú vs voseo), browser check of the three locales, API locale behavior, bin/ci. Route: gentle-ai-verify + parent fixes. Commit: fixes in the commit after `2604b83`.

## Conventions for workers

- Same as `odd/tasks/phase-4-finish-site.md` "Conventions for workers" (run via `/tmp/gss-run`, layers, cops, test-first for server behavior, no new gems, do not commit). Workers cannot delete files.
- Translators: read the English file fully and translate it faithfully per C3/C6 — no new facts, no omissions, same structure. Do not edit English files.

## Log

- L1 (user, verbatim): S1.
- L2 (decision): parent proposed path-prefix locales, shared slugs/progress, agent-facing English; user chose S2.
- L3 (evidence T1–T5): first parallel round stalled after 3–4 lessons per translator (budget); re-run as 17 batches of ≤4 lessons, all completed. Parent parity script over all es/es-AR lesson and demo files vs English: 0 issues (frontmatter keys title/description/module only, heading counts, byte-identical code blocks); no voseo in es. T1 needed two follow-ups: 29 → 41 rubocop offenses from helpers with instance variables and a lost footer "Report a problem" link; fixed with app/presenters/locale_context.rb. 135 examples, rubocop clean, bin/ci passed.
- L4 (evidence T6, gentle-ai-verify): routes/404s, html lang, hreflang, content overlay + fallback code path, API ?locale= (400 exact), llms.txt Language rules, demo /es, all-file structure and register scan, es-AR browser flows (home enroll, mark complete, handshake → localized confirmation + localStorage) PASS. FAIL fixed by the parent test-first: (a) English switcher/alternate href "" on /es and /es-AR home → base path "/" (RED: got ""); (b) language cookie written but never read → removed and C2 amended: the URL is the language (RED: cookie present); (c) "Report a problem" left in English in es and es-AR welcome lessons → "Reportar un problema". 136 examples, rubocop clean. Test students created by the verifier were deleted.
