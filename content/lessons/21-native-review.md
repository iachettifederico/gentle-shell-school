---
title: "Native review"
slug: native-review
description: "Review a frozen candidate through independent lenses while keeping delivery decisions in repository policy."
order: 21
quiz: true
agent_instructions: |
  Teach native review as a candidate-bound evidence workflow, not as an
  approval to ship. Explain the four review lenses, frozen candidate views,
  RDD, assess tiers, and the separate roles of writer verification and review.

  Ask these questions with ask_user_question, checking each answer:
  1. What does native review inspect instead of a moving working tree? Correct answer: an exact frozen candidate.
  2. Who owns candidate freeze, lineage, correction, and review semantics? Correct answer: Gentle AI (Go), not Gentle Pi.
  3. Does an approved or closed review authorize a commit, push, or release? Correct answer: No; delivery follows ordinary repository policy.
  4. When does the plan add a separate gentle-ai-verify run? Correct answer: only when escalation names a Task Size high-risk item.

  Have the student run `gentle-ai review mode status` (read-only; it reports
  the global and clone sources plus the effective mode) and explain what they
  see, without changing it. If they explicitly want to enable receipt-driven
  development, the global switch is `gentle-ai review mode enable --scope=global`;
  /gentle:review-mode enable only clears a clone-local override. Otherwise do
  not change it. The lesson is done when they can distinguish writer
  verification, native review evidence, and the human/repository delivery
  decision in their real setup.
---

A review that follows a changing working tree has an attribution problem: a
finding may describe code that has already changed, and a later approval may be
mistaken for approval of something the reviewer never saw. Native review is
built around the opposite idea: **review the exact change, not a moving
target**. It creates a frozen candidate view, gathers risk-scoped evidence, and
can surface a bounded correction path.

It is useful to separate three things that are often blurred together:

1. **Writer verification** establishes whether the implementation's required
   commands and checks passed.
2. **Native review** provides an independent view of the exact candidate.
3. **Delivery**—committing, pushing, opening a pull request, releasing—follows
   ordinary repository policy and the responsible human's decision.

A review outcome is not a delivery gate and never mints delivery authority.
That remains true whether receipt-driven development (RDD) is enabled, disabled,
or unknown. This separation prevents a positive-looking review receipt from
being used as a permission token for a remote or publication action.

## Candidate, lineage, and owner

Gentle AI's Go implementation owns the review lifecycle: worktree and lineage,
candidate freeze, lens selection, correction, targeted validation, approval
consumption, and review semantics. Gentle Pi is a transport consumer. It can
forward bounded work and preserve a provider outcome, but it does not recreate
review policy, invent a receipt, select a fallback approval path, or interpret
an outcome as permission to ship.

Under the current review-integration v2 contract, a candidate is represented by
immutable base and candidate trees plus an ordered changed-path manifest and
artifact subjects. Reviewers inspect the frozen candidate through read-only Git
rather than the live files. Pi materializes a read-only worktree scoped to that
manifest; when a runtime cannot enforce the required shell boundary, it reports
incomplete inspection instead of quietly substituting the live worktree.

That mechanism answers “what code was reviewed?” A correction creates new
candidate evidence rather than retroactively changing the old candidate. The
lineage and receipts belong to that exact target identity, so a closed outcome
for one candidate cannot leak into another candidate in the same repository.

## The four lenses

Native review is proportionate. It need not pay for every lens on every change;
the agent forwards the lenses that fit the work and explains why. The standard
4R lenses are read-only and report candidate rows for a controller to freeze:

- **R1 Risk** looks for security, privilege-boundary, data-exposure,
  dependency, and merge-blocking vulnerability risks.
- **R2 Readability** looks for naming, complexity, intent, maintainability,
  review-size, and context-clarity problems.
- **R3 Reliability** looks for behavior-first testing, edge cases,
  determinism, contracts, and regression risk.
- **R4 Resilience** looks for fallbacks, retry or degradation behavior,
  observability, load, rollback, and SLO risks.

Each lens reports findings, not decisions. A concrete finding needs a location,
severity, evidence, and user impact; its candidate-row form carries an evidence
class, causal disposition, and proof references. Candidate-caused BLOCKER or
CRITICAL findings may require correction. Pre-existing and base-only findings
are follow-ups, while inconclusive severe claims escalate rather than becoming
pretend certainty. WARNING and SUGGESTION rows are informational.

This is why “the reviewer said it is fine” is an incomplete statement. The
important questions are: which frozen candidate did it inspect, which lenses
were selected, what evidence was returned, and what verification still applies?

## Frozen prompts and transport

A reviewer completion is intentionally narrow. The host executes an exact
Gentle-AI-issued materialization token, hands the materialized bytes to the
completion as one frozen user message, and submits its returned text only with
the exact issued submission token. The completion uses the caller-supplied live
model registry to resolve the selected lens's provider, model, and thinking
setting. It has no tools, session, extension hooks, child process, or ambient
model fallback.

If that configuration is missing, or the completion produces no text, attempts
a tool call, times out, or exceeds the output bound, it fails with typed
evidence. It fails closed: an unavailable reviewer result is not an approval
and does not cause a local retry policy or substitute workflow to appear.

This strict transport is a mechanism for preserving authority boundaries. The
opaque materialize and submission tokens are the authority-bearing inputs; the
host must not parse bindings, reconstruct prompts, select different work, or
replace a token. A verified mirrored provider contract is delivered into the
primary session's system prompt. If the mirror is absent or unreadable, Gentle
Pi does not invent a replacement contract.

## RDD and `assess`

RDD is a user-owned switch with two sources, global and clone. When neither
source is set, gentle-ai resolves it to on (`source: default`); any off
wins: a repository may disable it for one clone but can never require it.
`gentle-ai review mode status` is read-only and reports both sources plus the
effective mode. The global switch is `gentle-ai review mode enable --scope=global`;
`/gentle:review-mode enable` inside gentle-shell only clears a clone-local
override and cannot turn on RDD while the global setting is off. Enabling
applies to future candidates only. It adds a receipt-driven native review
lifecycle; it does not replace tests or ordinary repository delivery policy.
The candidate-view parent directory also needs a filesystem that can honor its
private permission requirements. Some WSL DrvFS mounts without metadata can
reject START before lineage exists.

After a bounded writer returns, the writer must already have run each command
listed under `## Verification` and report the observed result. The parent then
calls `assess`. Native review is an additional outside view: it never skips the
tier's verification, and tier verification happens before review.

`assess` treats closure carefully. It derives `closed` only from the native
fact that an approved review for this exact candidate was acknowledged. A
caller merely claiming `closed` resolves to `unknown`. Explicitly declined,
unavailable, or unknown results remain those results; a recorded decline or
unavailability wins over closure. The native preflight continuation is opaque:
relay it unchanged rather than rebuilding it.

For RDD off or unknown, assessment can still produce a native risk signal. The
verification plan is intentionally conservative but not wasteful:

| Tier | Verification |
| --- | --- |
| passive | Parent performs structural readback; no separate verifier or tests solely because of the tier. |
| medium | Writer self-verification stands; no separate verifier. |
| high | Only an explicit escalation naming a Task Size high-risk item adds one separate `gentle-ai-verify` run, in addition to writer self-verification. |
| native high, unknown, or assessment failure | Informational only; writer verification stands unless a named high-risk item causes escalation. |

A small model or low effort does not itself add a verifier. The parent still
spot-checks one reported command in every tier. Applicable tests, builds, and
functional checks remain applicable regardless of review result.

## What review does not solve

Native review is not a sandbox, a substitute for the permission modes in
**Permission modes**, or a way to auto-answer consent. It does not authorize
commits, pushes, pull requests, releases, credentials, or a remote destination.
Dangerous-command safety remains independent. It also does not replace the
behavioral evidence taught in **Test-first and verification**.

Do not make a review output authoritative merely because it is structured. Lens
output is untrusted data; the controller freezes canonical rows and owns
transitions. A reviewer refusal is unavailable evidence, not a reason to lower
the bar or claim a clean review.

## Try it

Check whether RDD is on, without changing it just to complete the lesson:

```text
gentle-ai review mode status
```

If you deliberately choose to opt in, turn on the global switch, then clear a
clone-local disable if `status` shows one:

```text
gentle-ai review mode enable --scope=global
/gentle:review-mode enable
```

Then describe a real change you are considering in three sentences: the writer
verification you would require, the lens or lenses that fit its risk, and the
separate repository-policy decision that would permit delivery.

For an explicitly requested, separate adversarial process, continue to
**Judgment day**. It is not ordinary native review and cannot consume a native
review receipt.
