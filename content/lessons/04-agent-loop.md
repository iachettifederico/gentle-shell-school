---
title: "The Agent Loop"
slug: agent-loop
description: "Understand how Pi turns your message into model requests, tool calls, and recorded evidence."
order: 4
quiz: true
agent_instructions: |
  Teach the Pi agent loop as a repeatable mechanism: context assembly, provider
  request, streamed response, tool execution, recorded results, and another
  turn only when needed. Explain the difference between steering and follow-up
  messages, and why tools inherit the Pi process permissions.

  Ask these questions with ask_user_question, including the correct answer:
  1. What inputs does Pi use to build a model request?
     Correct answer: The system prompt, active branch, available tools, and
     model settings.
  2. What happens after a model response contains a tool call?
     Correct answer: Pi executes it and records the tool result.
  3. When does a steering message enter?
     Correct answer: After the current assistant turn.
  4. Does project trust sandbox tool calls?
     Correct answer: No; enabled tools use the operating-system permissions of
     the Pi process.

  Have the student submit a harmless request that calls a read-only tool, then
  identify the request, tool call, and result in the transcript. The lesson is
  done when they can explain why tool output can cause another model turn.
---

# The Agent Loop

A terminal agent can look like one continuous conversation, but it is a sequence
of model requests and recorded events. Understanding that sequence explains why
tool output appears in the transcript, why a request sometimes continues after a
response, and why a message typed while the agent works changes the next turn
rather than interrupting a tool halfway through.

## The loop begins with context, not just your last sentence

When you submit a message, Pi adds it to the active branch of the session. Pi
then builds a request for the selected provider from four core inputs:

1. the system prompt,
2. the active branch’s conversation history,
3. available tool definitions, and
4. current model settings.

The system prompt itself has layers. Pi starts with base instructions and
discovered context files. It also carries tool definitions and skill
descriptions. Full skill instructions load on demand, while extensions can add
instructions or transform context. Prompt templates expand editor input before
it becomes a user message. Selected files, images, pasted text, and shell output
can also become message content.

The result is a useful correction to a common misconception: the model does not
see your filesystem automatically, and it does not receive every possible
configuration file merely because it exists. It receives the assembled request
for the active Pi session.

## One turn: response, tools, results

Pi sends that request through the chosen provider. The provider streams an
assistant response. That response can contain ordinary text, tool calls, or
both. Pi records the response. For each tool call, Pi executes the tool and
records the result. This completes one turn.

A simplified flow looks like this:

```text
your message
  -> Pi assembles request
  -> provider streams assistant response
  -> Pi records it
  -> Pi executes requested tools
  -> Pi records tool results
```

Tool results are evidence for the agent’s next reasoning step. A `read` result
can reveal code to analyze; a command result can show a failing test; an edit
result can confirm that an intended file changed. If tool results or queued
messages require another model request, Pi starts another turn. Otherwise the
run ends.

That is why a request such as “inspect this directory and summarize it” may
produce several visible tool calls before the final explanation. The agent is
not secretly working between messages; Pi is cycling through explicit requests,
calls, and results.

## The active branch is the conversation context

Sessions are trees, but the active branch supplies history for the next model
request. Pi turns entries on that path into model-compatible user, assistant,
and tool-result messages. Branching and compaction, covered in **Sessions and
Context**, therefore affect what the next request contains without erasing raw
session history.

This matters when you change direction. A message is not an instruction written
directly into a model’s mind; it becomes a persisted session entry and then part
of a subsequent request assembled from the active branch. When the branch
changes, its supplied history changes too.

## Steering is different from a follow-up

Pi accepts new input while it is working, but timing changes the meaning:

- Submit with **Enter** to adjust the current task. The message waits until the
  current response and its tool calls finish, then guides the next response.
- Submit with **Alt+Enter** to add work after the current task. This queues a
  follow-up until Pi finishes pending work.
- Use **Escape** to abort the current task. Queued messages return to the editor.
- Use **Alt+Up** to return queued messages to the editor without waiting.

The agent-loop reference describes the same boundary: steering enters after the
current assistant turn; follow-ups enter after the agent finishes pending work.
This preserves a coherent tool-result sequence. It also gives you a practical
way to redirect work without destroying the text you have prepared.

## Tools are capabilities, not a sandbox

Pi’s built-in tool set can inspect files, run commands, edit content, and write
files. Extensions can register more tools. Tool availability is sent to the
model as definitions, but execution happens locally in the Pi process.

That means two security facts are both important:

- Project trust controls whether Pi loads project settings and resources before
  it loads context files.
- Enabled tools use the operating-system permissions of the Pi process.

Trust is valuable, but it does **not** sandbox tools. Review commands and
changed files, and use a sandbox for untrusted or unattended work. The model’s
ability to suggest a command does not make that command safe for a repository or
machine.

## Why records are part of the mechanism

Pi records assistant responses, calls, and results in the session. That supports
resuming work, rebuilding context, inspecting the transcript, and exporting a
session. It also explains why the transcript can contain sensitive material:
prompts, tool arguments, command output, file content, and credentials exposed
during conversation may be present. Review before sharing or exporting it.

The record is not just logging after the fact. Pi uses the active recorded path
to build later context. In an agent system, the trace is part of how the next
step is produced.

## Common mistakes

- **Expecting the model to know a file without a context or tool path.** Pi must
  include it in context or obtain it through a tool.
- **Reading tool calls as decorative output.** Their results often determine
  whether another turn begins.
- **Treating Enter and Alt+Enter as equivalent while work is running.** One
  steers; the other schedules follow-up work.
- **Treating trust as a sandbox.** It is not.

## Try it

Ask Pi for a harmless read-only task, such as listing a small documentation
directory and explaining its filenames. Watch the transcript: identify your
message, the tool call, its result, and the final response. Then imagine the
result revealed an unexpected file. Explain why Pi would need another model
request to decide what to do with that evidence.
