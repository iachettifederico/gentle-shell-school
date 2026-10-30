# Course alignment with Gentle Shell v4.5.1

Teach the latest release, gentle-pi v4.5.1 (2026-10-28). Restores the post-4.3.0 content from `course-gentle-shell-main` (all of it shipped in v4.4.0) and adds the v4.4.0–v4.5.1 changes.
English lessons first; `es` and `es-AR` mirror the same facts. Source of truth: `/tmp/gss-gs-451` at tag `v4.5.1`.

## Specs

- S1 Restore the reverted post-4.3.0 content (`odd/tasks/course-gentle-shell-main.md` S1-S7, except S5 which S2 replaces).
- S2 (L17) `/gentle:profiles`: "`/gentle:profiles` opens the models screen on the profile this repository resolves: one table, with your profiles as tabs across the top. It replaces the retired `/gentle:models`, which opened the same screen." Tabs: "`◉` this session, `★` the default for new sessions, `⌂` this repository. Leaving a profile with unsaved changes asks first: **Save and switch**, **Discard**, or **Stay**." "The orchestrator is the first row; agents follow." Buttons: "**Use in this session** (`u`) binds what you see to this Pi session only and switches its orchestrator; nothing shared is written. **Make default** (`d`) makes it the default for new sessions through the guarded global apply (diff confirmation, pin honesty, rollback). **Save** (`s` or `ctrl+s`) writes what you see into the profile." Profile menu `▾` (`m`): "**Rename**, **Duplicate**, **Use in this repo** (the clone pin ...), and **Delete**. **+ New** (`n`)". Subcommands: "`export <name>`, `import`, and `publish <name>` handle profile files and the repository declaration; `export-routing` and `restore-routing` move the saved global routing through `models.export.json`."
- S3 (L05) "`gentle-shell update --latest` (also with `pi`, `self`, `--self` or `--all`) installs the newest published stable Pi with the active Gentle Shell instead, without the release's verified lockfile: it first warns that Gentle Shell features relying on audited Pi internals (such as the Vim editor) may turn off until a Gentle Shell release verifies that Pi, then verifies and switches to it like `upgrade`, keeping the previous version for `gentle-shell upgrade --rollback`." "Outside a bundled install `--latest` changes nothing: `update` already installs the latest Pi."
- S4 (L08, L18) "The right rail scrolls **Status → Jobs → Agents → TODO**." "The Status card carries Project (cwd, branch, session name, active profile), Changes, and Integrations". "In fullscreen at 140 columns or wider, running jobs also get their own collapsible sidebar card (`⧗ Jobs`), one row per job with its elapsed time, newest first; it paints nothing only while nothing is current — no running jobs and no finished result still inside its 60-second tail, the Status card never repeats it, and `ctrl+shift+j` (or clicking the card's header) collapses it".
- S5 (L08/L28) Music: "gentle-stream runs on macOS and Linux, including Gentle Shell inside WSL. ... on native Windows `/gentle:music` only says it is not available yet". "a bundled Gentle Shell (the one the web installer sets up) offers to install the player for you the first time `/gentle:music` finds none".

## Tasks

- T1 S1 restore post-4.3.0 content (revert of 5e836e3) — inline — commit: 3935f86
- T2 S2-S5 English lessons — inline — commit: 188d69e
- T3 S2-S5 `es` and `es-AR` mirrors — inline — commit: eedd172
- T4 checks (`bin/ci`) and close — inline — commit: eedd172 (bin/ci green: 135 examples, 0 failures)
- T5 GPT 6.1 Sol review, apply agreed fixes — jd-judge-a (Sol) — commit: see L5

## Log

- L1 (user, 2026-10-29): "bro, we have a very new version of gentle-shell. Can we update the course for this version?"
- L2: installed `gentle-shell 4.5.1`, `pi 1.4.0`; GitHub latest release v4.5.1. Course on main teaches v4.3.0 (5e836e3). f60e4c9f (snapshot of `course-gentle-shell-main`) is an ancestor of v4.5.1; 19 commits between them.
- L3 (user): "sorry, I just activated yolo mode. Go ahead and when you finish run a review using GPT 6.1 Sol and implement the fixes it discovered if you agree. We'll check back tomorrow the ones you don't"
- L4: slice boundary: 3935f86 is a reviewed revert of bfb92eb (Judgment Day approved earlier), so the branch exceeds ~400 authored lines while new authored content is ~150 lines. gentle-ai-verify refused admission (no high-risk item); review routed to jd-judge-a, also openai-codex/gpt-6.1-sol.
- L5: Sol review: 3 findings, all confirmed against upstream and fixed in en/es/es-AR: JD-A-001 (MAJOR) lesson 17 "Use in this session" saves pending table edits to the profile first (docs/readme-reference.md:1101); JD-A-002 (MINOR) lesson 19 shared Engram server is bundled-install behavior (docs/bundled-install.md:251); JD-A-003 (MINOR) lesson 18 jobs card keeps only the 3 newest finished jobs (lib/jobs-widget.ts:17-20). None disagreed.
