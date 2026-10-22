# Phase 10 — Redesign (Gentleman Programming look, Refactoring UI principles)

Re-vamp the whole web design: dark Gentleman Programming look, built with Steve Schoger's Refactoring UI principles, accessible, in every language.
Branch `feat/phase-10-redesign`. Parent works inline; browser checks via headless Chromium over CDP.

## Specs

- S1 — "I want you to re-vamp again the web design. Still using gentleman programing as inspiration."
- S2 — "Please make sure that all the components look good (components, sections, bars, whatever)"
- S3 — "they're accessible"
- S4 — "and that all languages look good"
- S5 — "Use Steve Schroger's style." — clarified (L3): "I did mean the guy behind RefactoringUI"
- S6 — Base: "GP look with SS'principles is perfect." (dark Gentleman Programming look, Refactoring UI principles applied)

### Parent decisions

- D1 — Pure styling and markup: no behavior, route, or API change; new copy only for accessibility (`site.skip`, `site.main_navigation` in en/es/es-AR). JS changes limited to accessibility: copy announced via `[data-copy-status]` live region (and the label-reset bug fixed), completion badge keeps its spoken name. Existing `data-*` hooks, Stimulus targets, and spec selectors stay.
- D2 — Shared UI lives in partials under `app/views/shared/` (no view helper methods, per project cops).
- D3 — Accessibility target: WCAG 2.2 AA — text contrast ≥ 4.5:1 (≥ 3:1 large text and UI boundaries), visible focus on every interactive element, skip link, landmarks, current-page/language state exposed, copy feedback announced (`aria-live`), touch targets ≥ 24px, `prefers-reduced-motion` respected, no horizontal overflow at 320px.
- D4 — Languages: en, es, es-AR pages checked at 375px and 1280px for overflow, wrapping, and clipped labels (Spanish strings run longer).

## Tasks

- [x] T1 — Design system: tokens (palette with shades, spacing, type scale, shadows), base styles, focus ring, buttons/badges/cards as shared partials or component classes. Route: inline. Commit: `3d346b7`
- [x] T2 — Layout chrome: skip link, header with nav and language switcher, footer. Route: inline. Commit: `3d346b7`
- [x] T3 — Home: hero, start prompt, enrollment/progress card, syllabus modules and lesson rows. Route: inline. Commit: `3d346b7`
- [x] T4 — Lesson page: header, progress card, prose and code, lab, teach-me box, feedback link, prev/next. Route: gentle-ai-worker (context backstop). Commit: —
- [x] T5 — Enrollment pages (show, confirmation, expired, not found, already used) and 404. Route: gentle-ai-worker (context backstop). Commit: —
- [ ] T6 — Verify: browser screenshots of every page × en/es/es-AR × 375/1280, contrast and a11y audit, existing scenarios, `bin/ci`. Route: inline. Commit: —

## Design system reference (read before T4/T5)

- Tokens and components: `app/assets/tailwind/application.css` (`canvas/surface/raised/overlay`, `line`, `fg/fg-muted/fg-subtle`, `brand-50…950`, `success-*`; `.btn .btn-primary .btn-secondary .btn-ghost .btn-sm .card .eyebrow .link .chip .badge-success .prose-shell`).
- Partials: `app/views/shared/_prompt_card.html.erb`, `app/views/shared/_status_panel.html.erb` (render with `render layout:`). Reference page: `app/views/home/index.html.erb`.
- Slice boundary: commit 1 = `3d346b7` (T1–T3); T4/T5 are slice 2.

## Log

- L1 — User: "I want you to re-vamp again the web design. Still using gentleman programing as inspiration. Please make sure that all the components look good (components, sections, bars, whatever) they're accessible and that all languages look good. Use Steve Schroger's style. Do you need me to find a good web design skill for this task?"
- L2 — Parent: no skill needed; asked dark GP base vs light Schoger base.
- L3 — User: "GP look with SS'principles is perfect. And yes, I did mean the guy behind RefactoringUI"
- L4 — Parent: dev 500 found (Herb compiles `stylesheet_link_tag :app` without Propshaft expansion); fixed on main in `f98c2d7` (not pushed).
- L5 — User (mid-task): "after you finish, check the HERB analitics, I saw them in the UI, I'm not sure how to access them otherwise, but it might be a way" → follow-up after T6.
- L6 — T6 axe-core 4.14 audit (WCAG 2.0/2.1/2.2 A+AA + best practice) found lesson-body defects, fixed test-first in `spec/requests/lesson_body_accessibility_spec.rb`: `sanitize` stripped heading `id`s (in-page lesson links were dead) and anchor `aria-label`s (empty tab stops) → `config/initializers/sanitizer.rb` allows `id`, `aria-label`; code blocks used `<pre lang="bash">` (invalid lang) → `github_pre_lang: false`; Commonmarker's default `hardbreaks: true` turned every source newline into `<br>` → `hardbreaks: false`. Scrollable code blocks were keyboard-unreachable on mobile → code wraps (`pre-wrap`). Duplicate body `# Title` hidden; lesson column centered at 44rem with `prose-lg` (~76ch).
- L7 — Herb dev compiler renders a dynamic `data:` hash on `tag.*` literally (`data="{controller: …}"`), so `data-controller="enrollment"` was lost in `bin/dev` (tests/prod unaffected): pages now wrap the status panel in a literal `<div data-controller="enrollment" …>`, prompt card uses literal `data-prompt-text` (spec selector renamed from `[data-teach-me-prompt]`). Lesson status for a plain completion now reads "Completed ✓" instead of a bare "✓".
- L8 — Herb analytics (L5): `bundle exec herb analyze .` → 17 files clean; `bundle exec herb lint "app/views/**/*.erb"` (148 rules) found 8 errors in 3 files → fixed: `<a>` without `href` (JS-filled links get fallbacks), `.html_safe` → `lesson.track_html` i18n key, empty `do` block (feedback link moved into the teach-me card), empty `class`, `/>` spacing. Remaining: info-level suggestion to add `.herb.yml` `framework: actionview` (not applied: also changes Herb's dev compilation). Final checks: axe 0 failing (anonymous + enrolled, all page types × en/es/es-AR × 375/1280), 320px sweep 96/96 pages clean, behavior script 7/7 + enrollment handshake PASS.
