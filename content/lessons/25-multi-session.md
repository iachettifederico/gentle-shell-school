---
title: "Multi-session coordination"
slug: multi-session
description: "Coordinate active orchestrator sessions without mistaking metadata for authority."
order: 25
module: "Power user"
quiz: true
agent_instructions: |
  Teach cross-session coordination as a way to discover context and reduce
  duplicated work, not as a way to transfer authority. Explain subjects,
  published state, listing, metadata consultation, and the separate cost
  permission required for reasoning consultation.

  Ask these questions with ask_user_question, and verify the answers:
  1. What is a session subject for, and what is it not? Correct answer: it is
     a non-sensitive display and discovery hint, not authentication or routing identity.
  2. Why should metadata consultation precede a message? Correct answer: it can
     answer from published context without waking the owner or making a model call.
  3. Does a recent peer record prove a repository lock or exclusive ownership?
     Correct answer: no; reachability and ownership remain unknown.
  4. What needs explicit permission before reasoning consultation? Correct
     answer: the cost of its model call.

  Concrete setup check: ask the student to call orchestrator_session_id with a
  short non-sensitive subject and then use orchestrator_list without arguments;
  have them identify their current alias and stable routing ID in the result.
  Then demonstrate the course study-partner flow: have the student name their
  work-session subject, use orchestrator_list and metadata orchestrator_consult to
  follow published progress, and ask for model-cost permission before any reasoning
  consult. Done means the student can state what their session publishes, what a
  peer can safely infer, and when to consult versus message.
---

# Multi-session coordination

A second agent session can be useful long before it edits anything. You may have
one session investigating a failure, another preparing a review, and a third
working on a different repository. The hard problem is not opening those
sessions; it is learning whether nearby work matters without pretending that
names, windows, or old status imply permission.

Gentle Shell treats this as **coordination metadata**. A session can publish a
recognizable subject, a small curated progress snapshot, and bounded work
classification. Other sessions can list or search that published material, then
consult it or send a targeted message when a real question remains. This keeps
coordination cheaper than copying transcripts and safer than assuming that an
active-looking peer owns a file.

This lesson extends **Subagents**, not a replacement for it. A child task has a
parent and a declared handoff. A peer session is an independently running
orchestrator. Its public metadata is descriptive, not an instruction, grant,
lock, review receipt, or proof that it can receive your message.

## Start with a subject

Before delegating or coordinating work that is more than a small direct task,
call `orchestrator_session_id` with a short, non-sensitive `subject`. The tool
returns a stable routing ID, a current task alias, an initial task alias, and a
human session name. The aliases make a peer list understandable; the stable ID
is what identifies a recipient for a targeted operation.

A subject is deliberately limited. It is normalized and bounded, and it must
not contain a prompt or secret. Declaring it can set a Pi session name only when
that canonical name is empty, so a later human rename is preserved. The first
explicit subject remains the initial alias on that branch; a later declaration
updates the current alias. Neither alias becomes an identity or an access
control decision.

Publish only what another session needs to avoid a collision or ask a better
question. The same call can carry a small `state` object with `objective`,
`progress`, `decisions`, and `blockers`. It can also carry explicit classified
work, such as an area, topic, tags, and repository-qualified issue or PR
references. Treat this as a replace, not a patch: include every field that
should remain public. At completion, publish the outcome and next scope, or
withdraw the state rather than leaving a completed task looking active.

Do not put private history, credentials, raw prompts, or internal instructions
in this metadata. The implementation stores a bounded, non-context custom
record for the active branch; it does not mine your transcript to manufacture a
status report. That distinction protects both privacy and meaning.

## Discover first, infer modestly

`orchestrator_list` without arguments lists peers. It is useful for seeing
recent, same-profile orchestrators and their display labels, workspace context,
and bounded unfinished child-task summaries. A session can also request
classified-work search with an explicit filter. Filters can combine area, topic,
tag, literal text, an exact typed reference, or recorded repository root.

The result has important negative meaning. Recent presence is a heartbeat
window, not proof of reachability. A recorded workspace is a launch fact, not a
canonical repository identity or an exclusive-writer lock. Omitted, unknown,
unclassified, and pending pages mean the list is not exhaustive. A possible
area or tag overlap is only a possible overlap; it does not establish a
dependency or permission.

That restraint is the mechanism that makes a list safe to use. Instead of
inventing global ownership from a convenient dashboard, it makes uncertainty
visible. If you need exact context from a listed peer, retain the full stable
session ID returned by the tool. Do not select a peer by a clipped display ID
or an alias.

## Consult, then message only when necessary

`orchestrator_consult` has two lanes. The default metadata lane reads the
recipient's published snapshot. It does not wake the owner, launch a helper,
make a model call, or read private transcripts. It returns a detached,
bounded snapshot with historical timestamps and explicit unknowns. Use it first
for questions such as “what work did this session publish?” or “which repository
scope did it record?”

The reasoning lane is intentionally different. It asks a configured model a
bounded, read-only question over a curated public snapshot. Because it costs
money, an interactive UI must obtain model-cost permission; headless contexts
fail closed. Its answer is advice, not an owner reply, authority, or consent.
A model's prose cannot grant a permission that the original owner did not
publish.

When neither lane answers your question, send a targeted message through the
coordination tools with the peer's stable ID and a concrete reason. A queued
message means only queued, not delivered or read. Do not turn a lack of reply
into evidence that the peer is idle or that its files are available for you to
change.

## A practical sequence

Imagine two sessions both touch authentication. First, give yours a subject:
“Review login retry behavior.” Publish an objective and a blocker if there is
one. List peers. If another session has a possibly overlapping Auth topic, read
its published metadata. If it says it is changing the same validation rule,
message the owner with the focused decision you need. If it says nothing useful,
leave the uncertainty visible and coordinate with the human owner rather than
claiming the area.

This approach is cheaper than repeatedly asking an agent to summarize all of
its context, and it avoids the opposite failure: a vague “someone is handling
it” becoming a silent conflict.

## Common mistakes

- Using a display alias as though it were a stable recipient identity.
- Publishing secrets or long private reasoning in a status field.
- Treating a recent heartbeat as proof of delivery, ownership, or a Git lock.
- Calling costed reasoning when the published metadata already answers the
  question.
- Automatically paging or inferring that no search result means no related
  work exists.

## Try it

Declare a short subject for your current non-sensitive task. List peers and
read the coverage and unknown fields, not only matching rows. If a peer looks
related, consult its metadata and write down one fact it actually published and
one thing the result still cannot prove. That is the boundary that lets multiple
sessions coordinate without losing human control.
