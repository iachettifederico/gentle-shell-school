# Course alignment with Gentle Shell main (post v4.3.0)

Align course lessons with unreleased gentle-shell `main` (5ab58d4b, 2026-10-27; 4.3.0 is still the latest release).
English lessons first; `es` and `es-AR` mirror the same facts. Source of truth: `/tmp/gss-gs-new` at `origin/main`.

## Specs

- S1 (L23, L29) RDD: "RDD is optional and on by default (since Gentle AI v4.0.0). Turn it off anytime with `/gentle:review-mode disable` for this clone or `gentle-ai review mode disable` machine-wide; `/gentle:review-mode enable` only clears a clone-local off, and `status` lets you inspect the mode without changing it."
- S2 (L22) Super Yolo: "No permission prompts at all, including data-loss confirmations and configured guardrail actions. The only remaining line is the sensitive-path guard: read/write/edit of `.env`, `.ssh`, keychains, `*.pem/*.key/*.p12/*.pfx`, `secrets/` and cloud credential files stays hard-blocked. Code-level catastrophic denies (`rm -rf /`, `--no-preserve-root`, `git reset --hard`, forced clean, force push) also remain." Select with `/gentle:mode super-yolo`; default with `/gentle:mode default super-yolo`; children never inherit Super Yolo; ask_user/provider consent never auto-answered.
- S3 (L12) Small path: "read only what you change and its helpers, in one batch; observe RED inline before the fix; run the focused test and the suite inline in one command. ... no `todo`." High-risk item 1: "data or irreversible effects that cannot be rebuilt (... not saving new records, nor a dev or test database a seed or backup rebuilds)".
- S4 (L14) Differential check: "Only when your diff changes shared code (options, parsers, helpers) that an existing command the request did not name also uses, run one differential check before finishing, as a single script".
- S5 (L17) `/gentle:models`: "The `orchestrator` row selects the model and thinking effort that `u` will store in the current profile. ... Choose **leave untouched** ... to store no `orchestrator` key" and "`ctrl+s` saves only agent routing: it neither updates a profile nor applies the chosen orchestrator."
- S6 (L19) Engram: "Shell shares the global Engram server on `127.0.0.1:7437` ... when nothing listens, Shell starts the checksum-pinned Engram 3.5.2 core as a detached `engram serve` ... An existing store does not disable memory by itself ... Shell never stops or replaces a listening server."
- S7 (L08) Workspace: rail order "Status → Changes → Agents → TODO"; Agents card moves into the fullscreen rail when shown, else stays above the editor; paste-image key turns a clipboard image into an `[Image#N]` chip; optional `/gentle:design`, `/gentle:music`, `/gentle:voice`.

## Tasks

- T1 S1-S7 English lessons — inline — commit: a17384e
- T2 S1-S7 `content/lessons/es/` mirror — worker — commit: dfd392e
- T3 S1-S7 `content/lessons/es-AR/` mirror — worker — commit: dfd392e
- T4 checks (`bin/ci`) and close — inline — commit: dfd392e (bin/ci green: 135 examples, 0 failures, with node 24 on PATH)

## Log

- L1 (user, 2026-10-26): "now check the repository and update the course according to the latest version of gentle-shell"
- L2: installed gentle-shell is v4.3.0 (latest release, course already aligned in 1d6c19d); user chose "Update to main now".
- L3: bin/ci failed twice only because node was not on PATH (7 lab specs; direnv flake lacks node); green with nodejs-24.21.0 from the Nix store.
- L4: Judgment Day (Astra gpt-6-astra, Luna gpt-6-luna) on e5d16c4: 3 suspect CRITICAL from Astra (JD-A-001 lesson 19 Engram disable cases, JD-A-002 lesson 12 "small task can be high risk", JD-A-003 capstone resume test); user: "Fix all 3". Fixed in 9a3a5d1; bin/ci green (135). Re-judgment: 001/002 verified by both; 003 verified by Astra, "regression" by Luna (no claim given) -> escalated to the user.
- L5: user approved the JD-A-003 clarification ("yes, I think that's what we need to do"). Round 2 fix in c5a5c12; re-judgment: Astra and Luna verified JD-A-003; bin/ci green (135). JUDGMENT: APPROVED.
