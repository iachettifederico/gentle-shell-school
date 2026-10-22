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

- D1 — Pure styling and markup: no behavior, copy, route, or API change. Existing `data-*` hooks, Stimulus targets, and spec selectors stay.
- D2 — Shared UI lives in partials under `app/views/shared/` (no view helper methods, per project cops).
- D3 — Accessibility target: WCAG 2.2 AA — text contrast ≥ 4.5:1 (≥ 3:1 large text and UI boundaries), visible focus on every interactive element, skip link, landmarks, current-page/language state exposed, copy feedback announced (`aria-live`), touch targets ≥ 24px, `prefers-reduced-motion` respected, no horizontal overflow at 320px.
- D4 — Languages: en, es, es-AR pages checked at 375px and 1280px for overflow, wrapping, and clipped labels (Spanish strings run longer).

## Tasks

- [ ] T1 — Design system: tokens (palette with shades, spacing, type scale, shadows), base styles, focus ring, buttons/badges/cards as shared partials or component classes. Route: inline. Commit: —
- [ ] T2 — Layout chrome: skip link, header with nav and language switcher, footer. Route: inline. Commit: —
- [ ] T3 — Home: hero, start prompt, enrollment/progress card, syllabus modules and lesson rows. Route: inline. Commit: —
- [ ] T4 — Lesson page: header, progress card, prose and code, lab, teach-me box, feedback link, prev/next. Route: inline. Commit: —
- [ ] T5 — Enrollment pages (show, confirmation, expired, not found, already used) and 404. Route: inline. Commit: —
- [ ] T6 — Verify: browser screenshots of every page × en/es/es-AR × 375/1280, contrast and a11y audit, existing scenarios, `bin/ci`. Route: inline. Commit: —

## Log

- L1 — User: "I want you to re-vamp again the web design. Still using gentleman programing as inspiration. Please make sure that all the components look good (components, sections, bars, whatever) they're accessible and that all languages look good. Use Steve Schroger's style. Do you need me to find a good web design skill for this task?"
- L2 — Parent: no skill needed; asked dark GP base vs light Schoger base.
- L3 — User: "GP look with SS'principles is perfect. And yes, I did mean the guy behind RefactoringUI"
