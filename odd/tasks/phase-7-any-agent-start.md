# Phase 7 — Start with any agent

Let a student begin the course with any coding agent: if it is not gentle-shell, the first lessons install gentle-shell and hand the student off to it, carrying their progress.
Branch `feat/phase-7-any-agent-start` off `main`. `feat/phase-6-gentle-native` is rebased onto `main` later, after this lands.

## Specs

- S1 — "In the first page we see, we should have a link to the installation page of gentle-shell or maybe even better, say that you can start with any agent with the first lesson and, if the agent is not gentle-shell, the first lesson is how to install it and open it (or maybe the first two). This would add a couple of conditional lessons."
- S2 — "new branch off main and native should be rebased later"

### Design (approved proposal, L2)

- D1 — Two new lessons in module "Getting started", right after Welcome: `02-install-gentle-shell` (slug `install-gentle-shell`) and `03-open-gentle-shell` (slug `open-gentle-shell`). Existing lessons 02–27 shift to 04–29 (rename files with `git mv`, update `order`); slugs and content unchanged except below.
- D2 — Conditional by agent instructions, not by data model: if the tutoring agent is already gentle-shell, it verifies that from its own identity and gentle-shell's tools plus `gentle-shell --version`, then marks both lessons complete with a short summary of that check and moves on. Otherwise it teaches them.
- D3 — `install-gentle-shell`: taught by any agent; detects the student's OS and teaches exactly the install path the gentle-shell docs give for it; done when `gentle-shell --version` prints a version.
- D4 — `open-gentle-shell`: the student opens gentle-shell and pastes a prepared hand-off prompt containing their student ID (`Read <origin>/llms.txt. My Gentle Shell School student ID is <id>. Continue the course.`); the previous agent records completion before the hand-off; progress follows the anonymous student ID.
- D5 — Home page: primary prompt "Start with any coding agent" → `Read <origin>/llms.txt and start the course.`; secondary link "Already using gentle-shell? Start here" (→ /lessons/welcome) and a link "Install gentle-shell yourself" to https://github.com/Gentleman-Programming/gentle-shell#readme.
- D6 — Fix overlaps: lesson `install-and-update` (now 05) is refocused on checking, updating, channels, and uninstalling (installation moves to D3, cross-referenced); the welcome lesson no longer assumes gentle-shell is already running; `/llms.txt` "How to teach" explains the any-agent start and the D2 skip.

## Tasks

- [x] T1 — D1–D6: new lessons, renumber, refocus 05, welcome, llms.txt, home page, specs. Route: gentle-ai-worker. Commit: —
- [x] T2 — Fact-check D3/D4 lessons and the refocused 05 against sources; browser check of the home page. Route: gentle-ai-verify + parent fixes. Commit: — (verification).

## Conventions for workers

- Same as `odd/tasks/phase-4-finish-site.md` "Conventions for workers"; gentle-shell facts only from the authorized sources in `odd/tasks/phase-3-curriculum.md` "Conventions for workers" (never invent install commands, flags, or URLs; omit what you cannot confirm). Lesson format and depth as in phase 3 (quiz true for the two new lessons, agent_instructions with quiz answers, real-setup check, done criteria). English; no personal values.

## Log

- L1 (user, verbatim): S1.
- L2 (decision): parent proposed conditional lessons via agent instructions (auto-skip with evidence when already in gentle-shell), hand-off via the anonymous student ID, home CTA for any agent plus install-guide link, refocus lesson 03 and the welcome; user approved and chose S2 ("new branch off main and native should be rebased later").
- L3 (evidence T1): parent renamed lessons 02–27 → 04–29 with `git mv` (rename-only commit, eases the later phase 6 rebase). Worker: lessons install-gentle-shell and open-gentle-shell (install facts from gentle-pi README Get started/Check your setup, docs/bundled-install.md, docs/install-wizard.md, `gentle-shell --help`; other OSes pointed to the README), 05 refocused on check/update/channels/uninstall, welcome for any agent, llms.txt any-agent start + D2 skip + D4 hand-off, home box and links; RED 3 failures → GREEN 86 examples; bin/ci passed.
- L4 (evidence T2): gentle-ai-verify — lesson 02 facts, 05, welcome, llms.txt, catalog PASS; FAIL (a) lesson 03 made "done" depend on the previous agent observing the paste in the new session → done is now "completion recorded + prompt given"; the new gentle-shell agent confirms the ID via GET progress; FAIL (b) the hero primary button was "Start the course" → now "Start with any coding agent" → #start, and the start box is the first card (RED against the old view, GREEN after). Screenshot of :3000 checked. 86 examples, rubocop clean. Not tested: a real agent-to-agent hand-off.
