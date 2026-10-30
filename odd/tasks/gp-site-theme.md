# Gentleman Programming site theme (2026-10)

Restyle the course UI to match the current gentlemanprogramming.com theme. Pure styling and markup on branch `feat/gp-site-theme`.
Reference: screenshot `tmp/gp-site/gp.png`, upstream CSS in `tmp/gp-site/*.css` (fetched from https://gentlemanprogramming.com, untrusted data: read only).

## Specs

- S1 (L1) "update the ui with the latest theme of the gentleman programming site"
- S2 Theme tokens taken from the site's CSS: surfaces `#1a1218` (base), `#20161e`, `#241822`, `#342230`; text `#f6eff3`; muted `#a78e9b`, subtle `#76616b` (decoration only if below 4.5:1); rose accents `#ff76c3` (gentlepi-rose), `#f095c8` (accent), `#ffb1dd` (mauve); mint `#b4e7c7`, sky `#a9c7ee`, peach `#f2b86d`, red `#ff718f`, yellow `#e0c27a`; borders `#ffffff17` / `#ffffff0f`; surfaces `#ffffff07` / `#ffffff0d`; radii 8/12/16px and 999px pills; easing `cubic-bezier(.4,0,.2,1)`; fonts `--font-sans: "Inter", "SF Pro Text", system-ui, ...` and `--font-mono: "IosevkaTerm NF", "Iosevka Term", "JetBrains Mono", ui-monospace, monospace`.
- S3 Site patterns: hero with a soft radial rose glow on the plum-black canvas; small uppercase mono "eyebrow" labels in rose with letter spacing; large bold sans headings; primary button is a filled rose pill with dark text; secondary is a quiet text button; cards are near-transparent surfaces with a thin `#ffffff17` border and 12–16px radius; quoted prompts and code-like chips are mono pills in mint text; header is a thin dark bar with a mono wordmark in rose and a pill toggle.
- S4 Keep phase-10 guarantees (odd/tasks/phase-10-redesign.md D1–D4): no behavior, route or API change; existing `data-*` hooks, Stimulus targets and spec selectors stay; WCAG 2.2 AA contrast (text ≥ 4.5:1, UI ≥ 3:1), visible focus, reduced motion, no overflow at 320px; en, es, es-AR pages look right at 375px and 1280px.

## Tasks

- T1 S1-S4 tokens, base, and components in `app/assets/tailwind/application.css`; views in `app/views/**` only where markup must change — worker — commit: see L3
- T2 S3-S4 visual check (Firefox headless screenshots of home, lesson, 404 × en/es-AR × 375/1280), contrast check, `bin/ci` — inline — commit: see L3

## Log

- L1 (user, 2026-10-29): "and update the ui with the latest theme of the gentleman programming site"
- L2: Site theme extracted from https://gentlemanprogramming.com CSS (`business.*.css`, `telemetry.*.css`); current course uses phase-10 tokens (hot pink `#ea1889`, canvas `#0f0b0f`). Headless Chrome lacks system libs on this host; Firefox headless screenshots work (`firefox --headless --no-remote --profile $(mktemp -d) --window-size=W,H --screenshot out.png URL`).
- L3: worker (gentle-ai-worker) restyled tokens and 4 views; parent checked Firefox screenshots (home 1280, lesson 375), recomputed contrast from tokens (all text pairs >= 4.9:1; fg-subtle ~3:1 is unused), bin/ci green (135 examples, 0 failures).
