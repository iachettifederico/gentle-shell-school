---
title: "Sessions and Context"
slug: sessions
description: "Use Pi's JSONL session trees, branches, and compaction without losing the thread of work."
order: 7
module: "Foundations"
quiz: true
agent_instructions: |
  Teach sessions as persisted JSONL trees whose active branch supplies model
  context. Contrast resume, tree navigation, fork, and clone. Explain that
  compaction summarizes history for future requests while retaining original
  entries, and that it can be retried when a provider problem is fixed.
  Mention the per-session scratch directory and /gentle:scratch list|clean.

  Ask these questions with ask_user_question, including the correct answer:
  1. Which part of a session is sent as conversation history for the next
     request?
     Correct answer: The active branch.
  2. What does `/fork` create?
     Correct answer: A new session from an earlier user message.
  3. Does compaction delete the original session entries?
     Correct answer: No; it adds a summary entry while original entries remain
     in the session tree.
  4. What does `pi --continue` select?
     Correct answer: The most recent session for the current working directory.

  Have the student run `/session`, then `/name <a meaningful name>` in a
  disposable or current session. The lesson is done when they can explain when
  to use `/tree`, `/fork`, `/clone`, and `/compact`.
---

# Sessions and Context

A useful agent session must survive more than a single response. Pi saves a
conversation as a **session** and uses it to reconstruct the context for later
requests. The subtle but important part is that a session is a tree, not a flat
chat log. That design lets you revisit an earlier decision or explore another
approach without destroying the work you left behind.

## What Pi persists

Persistent sessions are JSONL files: one JSON object per line. Plain Pi stores
them under `~/.pi/agent/sessions/` by default, grouped by working directory.
Gentle Shell runs in its own isolated home by default, so its sessions live
under `~/.gentle-shell/agent/sessions/`; started with `--link`, it shares Pi's
home and Pi's sessions. The
file begins with metadata, and its later entries use IDs and `parentId` links to
form a tree. Session entries can record messages, model changes, thinking-level
changes, compaction summaries, branch summaries, usage, labels, and extension
state.

The tree is more than storage detail. Each path through it is a branch. The
branch ending at the current entry is the **active branch**, and it supplies the
conversation history for the next model request. Pi does not put every abandoned
alternative into the next request merely because it remains in the same file.

By default Pi saves sessions automatically. `--no-session` makes a run
ephemeral, so it cannot be resumed after Pi exits. You can place sessions
elsewhere with `--session-dir`, `PI_CODING_AGENT_SESSION_DIR`, or the `sessionDir`
setting; the CLI option has the highest precedence.

## Continue, resume, and name work

From the same working directory, resume the most recent session with:

```bash
pi --continue
```

Use `pi --resume` to open the session picker. Inside interactive Pi, `/resume`
opens that picker, while `/new` starts a fresh session. Give a session a useful
name with `/name` or `--name`; a name makes the session easier to recognize than
its first prompt. `/session` shows the current file, ID, message count, token
usage, and cost.

These actions have different jobs. Continuing says “take me back to the recent
thread for this folder.” Resuming says “let me choose a saved thread.” Naming
says “make this thread recognizable later.” Starting new says “do not continue
this conversation.”

## Four ways to explore without losing history

Pi offers related but different branching workflows:

| Action | Result | Best use |
|---|---|---|
| `/tree` | Move within the current session file | Keep related alternatives together |
| `/fork` | Create a new session from an earlier user message | Give an alternative its own session |
| `/clone` | Copy the current active branch into a new session | Make a separate copy of the current state |

In `/tree`, choosing a user message puts its text back in the editor. Edit and
submit it to create another branch. Choosing an assistant response or another
entry continues after that entry with an empty editor. This makes tree navigation
particularly useful when the original request was nearly right but needs a new
variant.

Forking separates the alternative into a new session from an earlier user
message. Cloning separates the current active branch as it now stands. Neither
is a magic rollback of files in the working directory: session branching manages
conversation history. Inspect and manage repository changes separately.

When you leave a branch through tree navigation, Pi can summarize the abandoned
path and attach that summary to the branch you enter. This preserves relevant
work without sending every prior message.

## Context is finite, so Pi compacts it

The model request contains the active branch together with the system prompt,
context files, tools, and skill descriptions. Long conversations approach a
model’s context limit. Pi normally compacts older history when the active
context approaches that limit, and you can compact manually:

```text
/compact
/compact Preserve the API decision and the open risks.
```

Compaction adds a summary entry and retains recent messages. It does **not**
delete original entries from the session tree. For subsequent requests, Pi uses
the summary in place of the older span plus the entries from a stored kept
boundary onward. The raw entries still support transcript history and other
session operations.

This is why a concise instruction to `/compact` can matter: it tells the
summarizer which topic or decision must survive into the compressed context. It
is also why compaction is not an excuse to avoid durable project records for
large work; a summary is a context-management tool, not a feature specification.

Automatic compaction can fail when the provider is unavailable or cannot accept
the summarization request. Fix the provider issue and run `/compact` again.
Disabling automatic compaction does not disable the manual command.

## What a compaction actually changes

Pi finds a cut point, summarizes messages before it, and appends a
`compaction` entry with a `firstKeptEntryId`. Context reconstruction uses the
latest compaction on the active path: the summary represents older material and
messages beginning at that kept ID remain available. The summary request omits
thinking blocks and truncates serialized tool results, which keeps the summary
within a workable size.

The session file therefore distinguishes two questions:

- What was originally recorded?
- What is currently visible to the model as context?

A `context_edit` can additionally omit or replace an earlier entry for future
model context without changing raw history, UI, exports, or session accounting.
That is an advanced session-format detail, but it reinforces the same principle:
Pi can revise future context while preserving the underlying record.

## Session scratch

Since v4.3.0, every primary Gentle Shell session gets its own scratch
directory (named `gpXXXXXX`) and runs with `TMPDIR` pointing at it, so every
`mktemp` the agent runs lands there. Each subagent gets its own `gaXXXXXX`
directory under it. If the scratch cannot be created, the session keeps the
inherited `TMPDIR`. A ledger in the config home records the scratch and each
clone or worktree that a successful foreground `git clone` or `git worktree add`
creates in the session.

Cleanup is automatic for scratch only: shutdown removes the session's scratch,
except the `TMPDIR` of a live or quarantined subagent (still running, or its exit
not yet confirmed), which stays with the scratch around it. A later session start
sweeps scratch left by sessions that ended more than an hour ago. Recorded clones
and worktrees stay until you clean them:

```text
/gentle:scratch list
/gentle:scratch clean
```

`list` shows the scratch with its size and the recorded clones and worktrees.
`clean` empties the current session's scratch without asking, keeping only
subagent scratch, recorded clones and worktrees, and entries changed in the last
minute, and removes the scratch that ended sessions left. Then it asks once
before removing recorded clones and worktrees that have no uncommitted or
unpushed work. Without a UI it removes scratch only. Another live session's
scratch is never removed, but your own is: save any file you still need from
`TMPDIR` before you run it.

## Common mistakes

- **Thinking a session is linear.** It is a tree, and the active branch matters.
- **Using `/clone` when you need an earlier alternative.** Use `/tree` or
  `/fork` from the earlier user message.
- **Treating compaction as deletion.** Original entries remain stored.
- **Assuming conversation branching undoes repository edits.** It only changes
  session history and future context.
- **Exporting a session casually.** It can contain prompts, tool arguments,
  command output, file contents, and credentials exposed in conversation.

## Try it

Run `/session` and give the session a recognizable name with `/name`. Then open
`/tree` and identify an earlier user message you could revise without deleting
the current path. Finally, describe what you would tell `/compact` to preserve
before a long investigation becomes too large for the current model context.
