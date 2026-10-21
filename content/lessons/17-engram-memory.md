---
title: "Engram Memory"
slug: engram-memory
description: "Use optional persistent memory to preserve verified context across Pi sessions."
order: 17
quiz: true
agent_instructions: |
  Teach that Engram is an optional companion package rather than gentle-pi
  itself, and distinguish durable project progress from an agent's current
  conversation context. Explain the save, search, context, and session-summary
  workflow only when the tools are active.

  Ask these questions with ask_user_question, one at a time:
  1. Does installing gentle-pi alone provide persistent memory? Correct answer:
     no; persistent memory comes from the optional gentle-engram companion.
  2. For a large ODD feature, what are the two progress copies to reconcile?
     Correct answer: the local odd/tasks feature document and its project-scoped
     Engram mirror.
  3. What should happen if Engram is unavailable while local progress can still
     be written? Correct answer: preserve local progress, mark the mirror
     pending, and do not claim persistence succeeded or block unrelated safe
     work.
  4. What should a resumed feature use in addition to a memory search? Correct
     answer: the actual task file and current code/evidence, reconciled before
     continuing.

  Perform this concrete setup check: ask the student to inspect the available
  tools in their running session and identify whether mem_context, mem_search,
  and mem_save are present. Do not ask them to expose memory contents. If they
  are absent, explain that the memory workflow is unavailable until the optional
  companion is installed. Done means the student can explain when durable memory
  helps, name the local source of truth, and safely describe the recovery order.
---

# Engram Memory

A conversation is useful while it is open, but a real development effort often
outlives one conversation. A terminal closes, a session is compacted, or a new
agent needs to continue work without re-discovering every decision. Persistent
memory addresses that continuity problem: it gives an agent a place to retain
small, reusable, verified facts and recoverable progress across Pi sessions.

First, keep the boundary clear. **gentle-pi does not provide persistent memory
by itself.** Engram is supplied by the optional `gentle-engram` companion
package. The package can be installed in a Pi home with:

```bash
pi install npm:gentle-engram
```

The presence of that command is not proof that memory is active in a particular
session. Look at the session's available tools before relying on it. When the
memory tools are active, the agent can save decisions, bug fixes, discoveries,
user prompts, and session summaries for later sessions. When they are not
active, ordinary files and the current session remain the available evidence.
This is why memory should improve a workflow, not become an undocumented
requirement for finishing routine work.

## Memory is a complement to repository evidence

Engram is most valuable when it preserves *meaning*, not a copy of everything
that happened. A useful saved observation is a concise, verified conclusion:
what changed, why it was necessary, where it applies, and any important edge
case. It is a poor place for raw source dumps, speculative conclusions,
credentials, or personal data. The save should remain understandable when read
weeks later and should point back to the source of truth: a task document,
repository path, test result, or other current evidence.

This distinction matters because memory and a repository have different jobs.
Git and files make the implementation inspectable. The ODD feature document
records the current agreed work. Memory helps an agent find that work and carry
forward a compact, searchable account of it. It must not silently replace a
file, invent a current state from an old note, or authorize a broader change.

For large ODD work, the durable pair is deliberately explicit:

1. the local feature document, such as `odd/tasks/<feature-name>.md`; and
2. an Engram mirror under the project-scoped topic
   `odd/<feature-name>/tasks`.

The mirror includes the full current document and its repository-relative
locator, rather than a vague completion message. The local document is written
first. Then the mirror is updated through the available memory save tool, and
both writes are read back. They are not one atomic transaction, so a successful
file write does not prove that the memory write also succeeded.

A `topic_key` gives related observations a stable identity. In the ODD pattern,
the feature topic keeps successive copies of one feature associated with that
feature rather than mixing them with unrelated work. The skill registry offers
another documented example: it uses the stable key `skill-registry` when memory
is available. A stable topic is a retrieval aid, not permission to overwrite an
unrelated record.

## A recovery sequence, not a guess

When an interrupted feature resumes, do not start from whichever memory entry
looks newest. That can revive a stale assumption or overlook a local update.
The documented recovery order is:

1. use `mem_context` to establish relevant memory context;
2. use project- and feature-scoped `mem_search`;
3. retrieve the full saved observation with `mem_get_observation`;
4. read the actual feature document; then
5. reconcile requirements, current code, and recorded proof before continuing
   the next unfinished task.

The order puts current, inspectable project evidence beside retrieved context.
If the local file and the mirror disagree, preserve both versions and surface
the real conflict rather than choosing based on a timestamp. A missing mirror
is not permission to overwrite the file that survived. Similarly, an unavailable
Engram service does not block unrelated safe work: keep local progress, state
that the mirror is pending, and resynchronize later instead of claiming success.

`mem_session_summary` serves a different but related purpose. A session summary
records a concise handoff at the end of a session: the goal, constraints,
discoveries, completed work, next steps, and relevant files. It reduces the
cost of picking up a conversation later, while the task document remains the
structured plan for a large feature. This complements Pi's **Sessions** lesson:
Pi can compact conversational context, whereas persistent memory is intended to
survive across sessions when the optional companion is available.

## Save selectively and with scope

A good rule is to save an observation after a meaningful, verified event: a bug
fix, a design decision, a non-obvious codebase discovery, a configuration
change, or a reusable project convention. Save conclusions, not a transcript.
For example, a completed migration of a feature document might be represented
as a compact observation tied to its project and topic, not as every tool result
that led there.

The permission boundary remains important. Explicit no-save or no-persistence
instructions win. The documented Auto-mode treatment for task-linked memory
also excludes secrets, deletion, maintenance, personal/global or cross-project
writes, and unrelated topic-key overwrites. In that mode, a qualifying project
memory write needs a successfully resolved current project and a subsequent
save or session summary that supplies the same project and working directory.
A self-asserted project name is not enough.

## Try it

In a session where memory tools are visible, ask the agent to name—not print—the
available memory tools. Then describe a real, non-sensitive fact you would want
a future session to know, such as a confirmed project convention. Explain its
project scope and stable topic before saving anything. Finally, imagine the
memory service is unavailable: write down what remains in the repository and
what should be marked pending.

The goal is not to save more. It is to make the next safe action easier to
recover: locate the right work, verify it against the repository, and continue
without mistaking remembered context for proof.
