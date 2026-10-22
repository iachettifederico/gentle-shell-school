---
title: "Judgment day"
slug: judgment-day
description: "Use a bounded blind dual adversarial review without turning reviewer output into delivery authority."
order: 22
module: "Safety and review"
quiz: true
agent_instructions: |
  Teach Judgment Day as an explicitly requested, standalone, blind dual-review
  process. Cover the two judges, frozen candidate rows, two-round limit,
  surgical fix boundary, final verdicts, and its independence from ordinary
  native review and delivery.

  Ask these questions with ask_user_question, checking each answer:
  1. How many judges and refuters start a Judgment Day review? Correct answer: exactly two blind judges and zero refuters.
  2. May a judge fix code during initial discovery? Correct answer: No; initial discovery is read-only and returns candidate rows only.
  3. What happens to severe findings that survive round two? Correct answer: they escalate; there is no third round.
  4. Does Judgment Day authorize a commit, push, pull request, or release? Correct answer: No; it creates no delivery authority and ordinary repository policy remains in control.

  Have the student inspect the current change with git diff --stat and state
  one exact target they would give to an explicitly requested Judgment Day
  review. Do not start Judgment Day unless they explicitly request it. The
  lesson is done when they can distinguish initial discovery from scoped
  re-judgment, state the two-round limit, and name the delivery boundary.
---

Some changes deserve a deliberately adversarial second look. The danger is
turning that desire into an endless swarm of reviewers, mutable claims, and
vague “looks good” conclusions. **Judgment Day** is Gentle AI's bounded answer:
an explicitly requested, standalone dual review with a fixed target, two blind
judges, frozen findings, at most two correction rounds, and one terminal
judgment.

It is separate from the workflow in **Native review**. Judgment Day does not
enable, replace, start, configure, or consume ordinary review for a lineage. An
ordinary review requested separately remains independent. Neither process
authorizes delivery: commit, push, pull request, release, and publication
remain ordinary repository-policy decisions.

## Start only with an explicit request

Judgment Day is not a background quality ritual. It starts only when a user
explicitly requests “Judgment Day,” “Judgement Day,” dual review, adversarial
review, or an equivalent request. Before actors run, the controller resolves
one exact target, snapshots the complete scope, and binds the initial review
tree.

That activation rule protects both cost and meaning. Without an exact target,
two judges can review different versions or different scopes. Without an
explicit request, a helpful agent could create an expensive parallel process
that the user did not ask for. The goal is not more commentary; it is credible,
candidate-bound evidence for a consequential change.

## Initial discovery: two independent sweeps

Judgment Day begins with **exactly two blind judges**—judge A and judge B—and
**zero refuters**. They run concurrently with identical target criteria, but
they do not coordinate or rely on each other's conclusions. Both are read-only.

The normal discovery budget is one exhaustive read-only sweep per judge. A
full-4R-scale target—such as a hot authentication, update, security, or
payments path, or a change over 400 lines—may use at most two sweeps per judge.
There is no “keep looking until dry” loop. A bounded sweep makes the review's
cost visible and prevents the discovery phase from becoming an unbounded
investigation.

During initial discovery, judges run exactly once against the supplied
`initial_review_tree`. They do not persist state, mutate claims, launch other
actors, request fixes, validate fixes, or deliver anything. They return only
candidate rows. A useful candidate is concrete: it has a stable identifier,
exact location, severity, evidence class, and an evidence claim describing the
user impact. A clean review is an empty candidate list, not a skipped report.

The judges' focus differs enough to reduce correlated blind spots. Judge A
emphasizes correctness, regressions, missing tests, unsafe behavior, and a
mismatch with the request. Judge B challenges assumptions with emphasis on edge
cases, integration risks, test gaps, and user-visible regressions. Their output
is still untrusted data: it cannot authorize transitions, fixes, receipts,
gates, or delivery.

## Freeze claims before correction

The controller canonicalizes and freezes the candidate rows after both judges
return. That is a key mechanism. A later fix cannot silently rewrite the claim
it is supposedly addressing, and the re-judgment can be restricted to a known
set of IDs and a known diff.

Severity matters. WARNING and SUGGESTION candidates are one-time informational
rows and never schedule fixes. For severe rows that survive, the controller
asks for human approval when it is required, then authorizes one *scoped* fix
batch. The human and controller own that authorization; a judge cannot promote
its own finding into an edit instruction.

The fix agent is deliberately surgical. Its dispatch contains the explicit
Judgment Day activation statement, exact authorized severe IDs, a round number
(`1 of 2` or `2 of 2`), a frozen-ledger SHA-256, exact frozen rows, and allowed
edit surfaces. It fixes only those supplied IDs, preserves original design
intent, adds focused tests when behavior changes, and returns candidate-tree
and fix-diff evidence. It does not add findings, alter frozen claims, deliver,
publish, or start another actor.

This is a useful pattern beyond Judgment Day: constrain an editor by the
specific problem, candidate, and edit surface instead of giving an open-ended
instruction such as “make review happy.”

## Scoped re-judgment, not a new discovery pass

After the batch, re-judgment receives only the requested frozen IDs, their
exact hash-bound rows, and the fix diff. The judges resolve only those IDs and
regressions on the fix lines. They may not add fresh findings, change frozen
claims, request another fix, launch actors, persist authority, or repeat their
sweep.

For each supplied ID, the resolution is one of:

- **verified** — the supplied concern is verified as resolved;
- **corroborated** — the supplied concern is still supported; or
- **regression** — the fix lines introduce a regression relevant to the
  supplied scope.

This distinction keeps re-judgment honest. It is not a chance to expand scope
or transform a correction check into another full audit.

Judgment Day can use at most two correction/re-judgment rounds. If severe rows
survive the second round, they **escalate**. No third-round transition exists.
Escalation is a truthful result: it says the bounded process did not resolve
those risks, so a human must decide the next path rather than burning more
unplanned review cycles.

## Terminal evidence and boundaries

If no severe rows survive, the controller performs final verification and
stops. At the end it runs exactly one final verification and returns one of two
terminal judgments:

```text
JUDGMENT: APPROVED
JUDGMENT: ESCALATED
```

The result must include the target, frozen finding IDs, correction rounds used,
final-verification evidence, skill resolution, and the terminal judgment. It
must not claim that an actor's prose output or a prose ledger is authority.

Judgment Day is intentionally independent of delivery and dangerous-command
safety. It performs no commit, push, pull-request creation, release,
publication, or version change. If someone wants one of those effects, it is a
separate action under the repository's normal policy and the applicable
permission controls from **Permission modes**.

## Common mistakes

- **Starting it automatically after every change.** It needs an explicit user
  request and an exact target.
- **Letting judges coordinate before discovery.** Blindness is part of the
  independence mechanism.
- **Asking a judge to fix code.** Discovery is read-only; only an authorized
  scoped fix batch can edit.
- **Reopening discovery during re-judgment.** Re-judgment resolves supplied
  frozen IDs and fix-line regressions only.
- **Trying a third fix round.** Round-two survivors escalate by design.
- **Treating APPROVED as shipping permission.** It is review evidence, not
  authority to deliver.

## Try it

Without starting a review, inspect the size of the change you are considering:

```text
git diff --stat
```

State one exact review target—for example, the current candidate for a named
feature—and explain why it warrants an explicitly requested blind dual review.
Then rehearse the boundary: two blind judges discover; the controller freezes;
a human-approved scoped batch fixes; re-judgment resolves only frozen IDs; and
ordinary repository policy decides whether anything ships.

In the capstone, you can combine this only when its cost and independence fit
the change; it is a deliberate tool, not a default finishing step.
