---
title: "Commits and Slices"
slug: commits-and-slices
description: "Package coherent behavior into reviewable work units and keep oversized delivery explicit."
order: 15
module: "Organic Driven Development"
quiz: true
agent_instructions: |
  Teach commits as reviewable work units and explain the advisory review budget,
  delivery strategies, and chain choices. Keep the distinction clear between a
  work-unit commit, a PR slice, and authorization to push or open a PR.

  Ask these questions with ask_user_question, including the correct answer:
  1. What belongs with behavior in a work-unit commit?
     Correct answer: Its relevant tests and user-visible documentation.
  2. Is about 400 authored changed lines a code-golf target or hard cap?
     Correct answer: No; it is an advisory review budget and work must not be
     shrunk by removing tests, docs, comments, or whitespace.
  3. What are the three oversized delivery choices?
     Correct answer: Feature/tracker branch chain, verified default/main branch
     chain, or one single PR.
  4. Does choosing a delivery shape authorize a push, PR creation, or merge?
     Correct answer: No.

  Have the student run `git diff --stat` and, if commits exist, `git log
  --oneline -5` in a repository. Ask them to describe one commit as an outcome
  rather than a list of files. The lesson is done when they can identify a
  coherent work unit, its verification, and the delivery choice they would need
  if the feature exceeded the review budget.
---

# Commits and Slices

A commit is more useful than a timestamped bundle of files. In ODD it is a
**work unit**: a deliverable behavior, fix, migration, or documentation unit
that a reviewer can understand, verify, and roll back without disentangling
unrelated changes. Work-unit commits provide the foundation for reviewable PR
slices when a feature grows.

This lesson is about structure, not automatic delivery. A commit or a chosen PR
shape does not authorize pushing, opening a pull request, merging, or changing
review mode. Those remain separate human and repository-policy decisions.

## Commit by outcome, not file type

A weak split mirrors the directory tree: “add models,” then “add services,” then
“add tests.” None of those commits necessarily works on its own, so a reviewer
must reconstruct the feature across several changes.

A work-unit split tells a story instead. For example:

```text
feat(auth): add token validation domain model and tests
feat(auth): wire token validation into login flow
```

Each commit has one clear purpose and leaves the repository in a sensible state
when applied alone. Tests stay with the behavior they verify. Documentation
stays with the user-visible feature or workflow it explains. A good message
explains the outcome, not merely the file list, and rollback removes one coherent
unit rather than collateral work.

Before committing, ask:

- Does this commit have one clear purpose?
- Does the repository make sense after this commit alone?
- Are relevant tests and docs included?
- Can it be rolled back without reverting unrelated work?
- Does the message say what changed for the project or user?

ODD asks for Conventional Commit messages for its work units. This gives a
consistent, outcome-oriented history while keeping the actual acceptance proof
in the feature document.

## Tasks, commits, and candidates are different

A feature-document task is a unit of tracked progress. A commit may hold one or
more whole tasks with their tests and docs. A PR slice is the reviewable group of
commits that delivery exposes. These are related but not interchangeable.

The feature document records the commit holding each task as evidence. A
high-risk unit gets its own commit so it can be reviewed alone. The native review
candidate is that work-unit commit, or the PR slice when review is deferred; it
is never a TODO checkbox or the whole accumulated feature branch. Keeping these
boundaries clear lets verification and rollback target the actual change.

## The review budget is advisory

ODD uses about **400 authored changed lines**—additions plus deletions—as an
advisory review budget. It helps forecast reviewer workload and decide whether
to slice delivery. It is not a cap, a task classifier, a forced split, or a
reason to omit quality work. The same number may be configured differently for
a session.

Never fit the budget by deleting comments, blank lines, documentation, or tests,
or by compressing code. First make one honest slicing pass by coherent work unit.
If no cohesive split puts every slice under budget, report the smallest honest
count and why it cannot shrink further; do not iterate endlessly toward a
cosmetic number.

A focused PR of 400 lines or fewer is reasonable. An oversized PR increases
reviewer cognitive load, slows feedback, and couples rollback of otherwise
separable work. The chained-PR guidance aims to keep each PR reviewable in about
60 minutes.

## Delivery strategies

At feature-document creation, forecast authored changed lines from the tasks and
choose a delivery strategy. Keep a running count from work-unit commits. If the
forecast or running count exceeds the advisory budget, apply the selected
strategy before the next commit.

The default is `ask-on-risk`: ask once using the oversized-delivery menu. With
`auto-chain`, ask only if the chain choice is not already cached, then slice
automatically. `single-pr` keeps one PR subject to the destination repository’s
policy. `exception-ok` records an explicitly accepted policy exception where the
destination has such a route. A single-PR selection is not, by itself, an
accepted exception.

When a chain choice is needed, the choices appear in this order:

1. **Feature/tracker branch chain** (`feature-branch-chain`): child slices are
   reviewed before final feature integration.
2. **Verified default/main branch chain** (`stacked-to-main`): independently
   reviewable slices land in order on the repository’s verified default branch,
   whatever that branch is named.
3. **One single PR — least recommended** (`single-pr`): keep the oversized
   change together.

“Least recommended” applies only to an oversized single-PR menu. It does not
mean all single PRs are bad. The third choice clears any pending chain choice;
it is not itself a chain strategy. In noninteractive contexts where no question
can be answered, the ODD guidance uses the feature/tracker branch chain and
records that choice in the Log.

## What a chain requires

Before creating branches or PRs, verify the destination repository’s default
branch rather than assuming it is named `main`. Do not mix strategies once one
is chosen. In a chain, each child PR holds one deliverable work unit with its
tests and docs, describes its start and end state, dependencies, follow-up work,
and out-of-scope items, and includes a dependency diagram marking the current
PR.

A feature-branch chain uses a draft, no-merge tracker PR. The first child targets
the tracker branch; each later child targets the immediate parent branch.
A stacked-to-main chain instead uses the verified default branch as the
integration destination. If a child’s diff includes work from the wrong base,
treat that as a polluted-diff problem and correct the base so the reviewer sees
only the current unit.

For one single PR, do not create chain-only artifacts such as a tracker or child
dependency diagram. Follow the destination’s normal PR template and contribution
policy. `size:exception` is not a universal label: use it only if the destination
policy defines it and its authorization conditions are met.

## Useful local inspection

Before a commit, inspect both the story and size:

```bash
git diff --stat
git diff --cached --stat
git log --oneline -5
```

The diff statistics reveal the work under review; recent log messages show the
repository’s commit style. They do not decide task size or replace reading the
actual diff.

## Common mistakes

- **Separating tests into a later commit.** It makes the behavior temporarily
  unverified.
- **Splitting by folders.** Split by independently understandable outcomes.
- **Treating 400 lines as a hard limit.** Preserve coherent code and evidence.
- **Assuming `main`.** Verify the default branch.
- **Treating a chosen strategy as delivery permission.** Push, PR creation, and
  merge remain separate authorizations.

## Try it

Run `git diff --stat` and look at the current change. Describe its smallest
coherent outcome in one sentence, then list the tests and documentation that
belong with it. If the work would exceed the review budget, decide whether its
units can land independently or need feature-level integration. That tells you
which chain option you would present—without creating a PR or assuming that
approval to choose a shape is approval to deliver it.
