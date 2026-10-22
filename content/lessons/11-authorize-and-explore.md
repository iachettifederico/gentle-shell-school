---
title: "Authorize and Explore"
slug: authorize-and-explore
description: "Separate permission to investigate from permission to change a project."
order: 11
module: "Organic Driven Development"
quiz: true
agent_instructions: |
  Teach the authorization boundary and proportionate exploration. Emphasize that
  research, explanation, comparison, review, and proposals stay read-only, and
  that one focused question is for a real unresolved decision.

  Ask these questions with ask_user_question, including the correct answer:
  1. Does permission to investigate authorize a write?
     Correct answer: No; investigation is read-only.
  2. What should happen when implementation intent is ambiguous?
     Correct answer: Ask one clarification and wait.
  3. What should trigger a focused product question?
     Correct answer: A real unresolved product or design decision.
  4. What should research report besides facts?
     Correct answer: Assumptions, contradictions, freshness or gaps, plus a
     recommendation, tradeoffs, open questions, and implementation implications.

  Have the student choose a real repository request and list the smallest files
  or requirements they would read before editing. Then have them state whether
  its wording authorizes implementation. The lesson is done when they can name
  the authorization state, a proportionate exploration plan, and any one real
  decision that would justify asking a question.
---

# Authorize and Explore

Before an agent changes a repository, two questions need different answers:
**May it change anything?** and **What must it understand first?** Combining
them is a common failure mode. An agent can mistake a request for advice as
permission to edit, or it can begin implementation from a shallow reading that
misses the project’s actual constraints.

ODD answers the first question with authorization and the second with
proportionate exploration. They are consecutive steps because understanding
should precede a write, but they protect different things: human control and
technical correctness.

## Read-only is a real operating mode

Investigation, explanation, review, comparison, and proposal-only requests are
read-only. The agent may inspect code and requirements, describe findings, and
recommend a path. It should not create implementation artifacts, dispatch a
writer, or apply changes just because it has learned how it would solve the
problem.

The same boundary applies to research. Research can reduce uncertainty, but
research findings do not authorize new scope or acceptance. If external evidence
is needed, the agent establishes the problem, desired outcome, constraints, and
current evidence; it uses authorized sources, prefers primary sources, and
attributes material claims. Its result distinguishes verified facts from
assumptions, contradictions, freshness concerns, and gaps. A useful research
handoff also contains a recommendation, tradeoffs, open questions, and
implementation implications.

This boundary is valuable even when a requested change seems obvious. It means a
proposal can be safely examined without the repository changing underneath the
person who asked for it.

## What authorization looks like

Implementation authorization is permission to mutate the project within the
request’s scope. When that permission is clear, ODD proceeds to exploration.
When it is ambiguous or conditional, the agent asks **one clarification** and
waits. That question should be focused: it resolves whether change is wanted or
settles the one product decision that makes safe implementation impossible.

Do not turn every preference into an interrogation. If existing requirements and
repository conventions answer a question, use that evidence. Ask only when a
real decision remains unresolved. Likewise, hedged wording such as “I may review
commits later” does not order the agent to stop; it asks for resumable notes and
separate commits while authorized work continues. Only an explicit request to
wait is a stop instruction.

A well-shaped clarification gives a closed, meaningful choice. “What do you
want?” is broad and forces the requester to design the solution. “Should this
new field be optional or required for existing records?” identifies the actual
consequence and lets the owner decide it.

## Explore before the first write

Exploration reads the existing code and requirements first. “Proportionately” is
the key word. A narrow, known edit might need only the target file and its test.
A cross-cutting behavior may need the public interface, existing implementation,
related tests, configuration, and project instructions. The goal is not to read
the repository; it is to establish the evidence needed for the next safe action.

The orchestrator uses an evidence budget to keep this efficient. When
understanding fits one bounded read batch, it can work inline. When it needs more
than that—or more than roughly five sequential lookups—a read-only explorer can
map the relevant area and return concise `path:line` evidence. This trigger is
about missing understanding, not an excuse to delegate a small targeted
question. Reading that prepares a delegated write belongs with the writer; an
inline write reads inline.

Exploration should also validate consequential premises. If an assumption’s
failure would invalidate the approach, check it before building. Reuse reliable
findings from sibling work instead of re-reading them, then verify only what is
stale or materially different.

## Resolve uncertainty without manufacturing it

After exploration, distinguish a missing fact from an open decision. A missing
fact might be answered by reading a configuration file or an authorized primary
source. An open product decision—such as an incompatible behavior choice—belongs
to the human owner. Ask one focused question, then wait.

For a high-consequence but unproven premise, ODD permits at most one scoped,
independent, read-only challenge. Name the premise, the evidence for it, and the
consequence if it is wrong. This is not an invitation to debate deterministic
test failures: failures need a fix. It is a way to avoid building on an
unexamined assumption where the cost of being wrong is unusually high.

Unavailable evidence pauses only the dependent unsafe decision. It should not
block unrelated safe work or lead to invented facts.

## An exploration example

Suppose the request is: “Make the export include the project owner.” First ask
whether this authorizes implementation; if yes, inspect the export entrypoint,
the object supplying project data, the existing export tests, and any stated
format contract. You may discover that there are two export formats and that the
owner field’s required representation is not specified. That is a real product
decision. Ask one question about the representation rather than guessing.

If the request instead says “Explain where exports are assembled,” stop after
read-only exploration and report the evidence. Even a perfect implementation
plan would not authorize a write.

## Common mistakes

- **Editing while “just looking.”** A helpful cleanup is still a mutation.
- **Asking questions that code already answers.** Read first.
- **Asking several questions at once.** Resolve the decision that blocks the
  next action, then continue.
- **Over-exploring a narrow change.** Evidence should match consequence, not a
  fixed checklist.
- **Treating a research result as approval.** Findings inform an owner; they do
  not expand scope.

## Try it

Take a current request and write two sentences: one stating whether it grants
implementation authorization, and one naming the smallest evidence you need
before a first write. If a decision really remains, phrase one focused question
that explains what changes between the available outcomes. If no decision
remains, do not invent one—move on to classification in **Task Size and Risk**.
