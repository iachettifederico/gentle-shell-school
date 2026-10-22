# Phase 3 — Curriculum: in-depth gentle-shell lessons

Write the full lesson set that teaches gentle-shell in depth, as Markdown lessons in `content/lessons/`.
Branch `feat/phase-3-curriculum`. Writers and verifiers run on `openai-codex` model profiles to save tokens.

## Specs

- S1 — "write all the lessons you think we need in order to understand gentle-shell in depth"
- S2 — "Check the models we have available (keep in mind that the openai models should be used through the openai-codex provider and not the bare openai provider if you're gonna use them)."
- S3 — "Again, optimize for savings and go deep. I'd like this course to help me learn gentle-shell in depth"

## Syllabus

Order = file prefix. `01-welcome.md` already exists. Modules are a writing grouping only (the lesson format has no module field).

| # | slug | Topic |
|---|------|-------|
| **A. Foundations** | | |
| 02 | layers | Pi vs gentle-shell (gentle-pi) vs gentle-ai CLI vs Engram and other packages |
| 03 | install-and-update | Install paths, check setup, update/channels, uninstall |
| 04 | agent-loop | How Pi works: system prompt, context, tools, tool calls, the loop |
| 05 | sessions | Session JSONL trees, resume, branch/fork/clone, compaction |
| 06 | workspace-tui | TUI, command palette, slash commands, keybindings, Gentle Changes, Gentle Agents view |
| 07 | models-and-providers | Providers, models, thinking levels, subscription providers (e.g. openai-codex vs openai), NaN provider |
| **B. Organic Driven Development** | | |
| 08 | odd-overview | ODD's seven steps and why runtime discipline beats prompt engineering |
| 09 | authorize-and-explore | Read-only vs authorized work, clarifying once, exploring proportionately |
| 10 | task-size-and-risk | Small vs large, the resume test, high-risk items, the Risk line |
| 11 | feature-tracking | Feature document anatomy (Specs/Tasks/Log, verbatim quotes), Engram mirror, todo projection, resuming |
| 12 | test-first-and-verification | RED/GREEN, assertions on every observable effect, differential checks, verification rule |
| 13 | commits-and-slices | Work-unit commits, ~400-line slices, chained PRs, branch-pr |
| **C. Delegation** | | |
| 14 | subagents | explore/worker/verify roles, handoff by reference, allowed edit surfaces, delegation triggers |
| 15 | model-profiles | Per-agent model profiles, routing work to cheaper models, cost tradeoffs |
| 16 | background-work | bash_background, monitor, jobs, not polling |
| **D. Memory and skills** | | |
| 17 | engram-memory | Engram: what to save, search, context, session summaries, compaction recovery |
| 18 | skills | Skills, discovery, skill registry, bundled skills |
| 19 | writing-skills | Authoring skills: skill-creator, style guide, skill-improver |
| **E. Safety and review** | | |
| 20 | permission-modes | Normal, Auto, YOLO; boundaries that never auto-approve |
| 21 | native-review | Native review and RDD: candidates, lenses, assess tiers, receipts |
| 22 | judgment-day | Blind dual adversarial review and fix rounds |
| **F. Power user** | | |
| 23 | multi-session | Orchestrator sessions: subjects, listing peers, messaging, consult |
| 24 | extensions-and-packages | Pi extensions, packages, gentle-pi's bundled extensions |
| 25 | mcp-and-codemode | MCP servers, codemode scripts, web search/fetch tools |
| 26 | customization | Settings, themes, layout, sound notifications, prompt templates |
| 27 | capstone | Build a small feature end to end with ODD, delegation, memory, and review |

## Tasks

- [x] T1 — Module A lessons 02–07. S1, S3. Route: gentle-ai-worker (openai-codex/gpt-5.6-terra). Commit: `265505e`
- [x] T2 — Module B lessons 08–13. S1, S3. Route: gentle-ai-worker. Commit: `6f24f85`
- [x] T3 — Module C lessons 14–16. S1, S2, S3. Route: gentle-ai-worker. Commit: `870896b`
- [x] T4 — Module D lessons 17–19. S1, S3. Route: gentle-ai-worker. Commit: `19385e7`
- [x] T5 — Module E lessons 20–22. S1, S3. Route: gentle-ai-worker. Commit: `04652ed`
- [x] T6 — Module F lessons 23–27. S1, S3. Route: gentle-ai-worker. Commit: `9301448`
- [x] T7 — Fact check every lesson against sources; fix inaccuracies. S1, S3. Route: 3× gentle-ai-verify (openai-codex/gpt-6-sol) find, gentle-ai-worker fixes. Commit: fixes folded into the module commits above

### Slices

Content-only, one commit per module (lesson files are independent; each module is one review unit): A `265505e` (1046 lines), B `6f24f85` (960), C `870896b` (441), D `19385e7` (504), E `04652ed` (562), F `9301448` (834). Total ~4.3k lines of Markdown; no code changed.

## Conventions for workers

- Sources (user-authorized, read-only, L3): `G=/nix/store/ks22np34zbn7smr9663vpwilk9arrsf8-gentle-pi-4.3.0/lib/node_modules/gentle-pi` (README.md, docs/, assets/orchestrator*.md, assets/agents, assets/chains, skills/*/SKILL.md, contracts/, extensions/*.ts, prompts/), Pi docs in `$G/node_modules/@earendil-works/pi-coding-agent/docs/`, output of `gentle-shell --help`, `gentle-ai --help`, `pi --help`, and the shape only of `~/.gentle-shell/agent/settings.json`, `subagents.json`, `agents/`. Never read `auth.json`, `mcp-auth.json`, or `sessions/`.
- Every fact (command, slash command, setting key, path, tool name, behavior) must come from a source you read. If you cannot confirm something, leave it out. Never invent flags or commands.
- Public website: no personal values (no `/home/...` paths, no API keys, no one person's model choices). Use `~/.gentle-shell/...` and generic examples.
- Format: copy `content/lessons/01-welcome.md`. File `content/lessons/NN-slug.md`; frontmatter keys exactly `title`, `slug`, `description`, `order` (= NN), `quiz`, `agent_instructions`. Use `{origin}` for the course URL. English.
- Depth: each lesson body ~800–1500 words: the problem the feature solves, how it works (mechanism, not just usage), concrete commands/examples, common mistakes, and a short "Try it" section. Teach concepts before commands.
- `quiz: true` on all new lessons. `agent_instructions` must state: what to teach, 3–4 quiz questions with the correct answers (the agent asks via ask_user_question; no "Recommended" labels), a concrete check against the student's real setup (a command or observable), and what "done" means.
- Run `/tmp/gss-run 'bin/rspec spec/content spec/adapters'` after writing (every lesson must load). Do not commit; the parent commits.

## Log

- L1 (user, verbatim): "ok, so I'd like you to write all the lessons you think we need in order to understand gentle-shell in depth. Check the models we have available (keep in mind that the openai models should be used through the openai-codex provider and not the bare openai provider if you're gonna use them). Again, optimize for savings and go deep. I'd like this course to help me learn gentle-shell in depth"
- L2 (decision): course is in-depth for an experienced developer (the user is the target student). Subagent model profiles already use openai-codex (explore gpt-6-luna, worker gpt-5.6-terra, verify gpt-6-sol); the bare openai provider is not used. Syllabus designed by the parent from a codex explore feature map.
- L3 (user consent): read-only access granted to the gentle-pi package, CLI help output, and the shape of ~/.gentle-shell/agent settings/subagents/agents; auth.json, mcp-auth.json, and sessions/ are excluded.
- L4 (evidence T1–T6): 6 parallel gentle-ai-worker (codex) runs, 447 s wall time. 26 lessons 02–27, ~1,100–1,500 words each (32.6k words total incl. welcome), all quiz: true. Parent check: 27 files load, full suite 69 examples 0 failures, no personal paths/keys/model ids. Facts not yet checked (T7). First two launches rejected by the writer guard (missing `## Allowed edit surfaces` heading, then `Spec: <doc>, T<n>` format); third launch used the canonical format.
- L5 (evidence T7): 3 gentle-ai-verify (codex gpt-6-sol) runs, 82 s, checked 02–27 against sources: 21 PASS, 5 FIX. Fixed inline: 03 `gentle-shell update [target]` forwards Pi update, no target in bundled install runs `upgrade` (README.md:585); 14 explorer may initialize a CodeGraph index (assets/agents/gentle-ai-explore.md:20); 16 `job_stop` sends no notice but `/gentle:jobs` stops are reported (docs/gentle-shell.md:272); 19 Pi discovers SKILL.md directly, registry is a separate index (Pi skills.md:43); 21 RDD switch is `gentle-ai review mode enable --scope=global`, `/gentle:review-mode enable` only clears a clone-local override (extensions/gentle-ai.ts:5807-5809, parent confirmed). Upstream inconsistencies noted, not taught: gentle-pi README.md:146 still says enable via `/gentle:review-mode enable`; `gentle-ai review mode --help` says RDD is on by default while gentle-ai.ts:5809 says off by default; lesson 21 teaches `gentle-ai review mode status` instead of claiming a default. Full suite 69 examples, 0 failures.
- L6 (user, verbatim): "ok, please report both incidents, then commit, merge and push"
- L7 (evidence, corrects L5): an isolated `gentle-ai review mode status` (gentle-ai 4.2.0, temp HOME) returns `effective: on, source: default`, so RDD is on by default (gentle-ai #4801, closed completed). The stale side is gentle-pi v4.3.0 (README "RDD is opt-in", gentle-ai.ts "off by default until explicitly enabled"). Both are already fixed on gentle-shell main and unreleased: 145485c85 "fix(review): say RDD is on by default when the mode fails closed", cf2a9b9da "docs(review): say RDD is optional and on by default". No upstream issues filed (they would duplicate fixed work). Lesson 21 now states the default from that observed status.
