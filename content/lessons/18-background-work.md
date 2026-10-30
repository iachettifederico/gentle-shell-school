---
title: "Background Work"
slug: background-work
description: "Run and observe long-lived work without wasting turns polling it."
order: 18
module: "Delegation"
quiz: true
agent_instructions: |
  Teach the difference between a background command and a monitor, why events
  replace polling, how completion returns to the parent session, and how to
  inspect or stop session jobs.

  Ask these questions with ask_user_question:
  1. What does bash_background do when its command exits? Correct answer: it
     wakes the agent once with the completion result.
  2. What does monitor turn into events? Correct answer: each output line from
     a long-running command.
  3. Why should an agent not sleep and poll for a background result? Correct
     answer: completion is delivered as a session message, so polling wastes
     turns and can delay useful work.
  4. Which command opens the background-jobs inspector? Correct answer:
     /gentle:jobs.

  Check the student's real setup: have them open /gentle:jobs and identify
  whether the session has running or retained completed jobs. They may close it
  without starting or stopping a job.

  Done means the student can choose bash_background versus monitor, explain how
  event delivery avoids polling, and locate job status and stop controls.
---

# Background Work

Some useful commands take longer than one agent turn: a test suite, a build, a
server, or a watcher that emits meaningful updates over time. Waiting badly is
surprisingly expensive. If an agent repeatedly sleeps and asks “is it done
yet?”, it burns turns without learning anything. If it blocks on a command that
should keep running, it cannot respond to the next useful event.

Gentle Shell provides two related mechanisms for this situation:
`bash_background` and `monitor`. Both move the wait into the runtime, where the
completion or output can be delivered back to the parent session. They do not
make a command harmless, authorized, or correct. The command's scope and
permission requirements still matter. Backgrounding is a waiting strategy, not
a safety exemption.

## A completion versus a stream

Use **`bash_background`** when the important event is that a command finishes.
It starts the command in the background and wakes the agent once when the
command exits. This fits bounded work such as a long test run or build: the
parent can continue with non-overlapping work, then receives the completed job
result rather than spending turns checking a status file.

Use **`monitor`** when a long-running command's output lines are themselves
important. A monitor turns each output line into an event. It is suited to a
process whose stream tells the agent something actionable while it runs, rather
than merely producing one final exit result. The difference is semantic:
background execution asks “tell me when this finishes”; monitoring asks “tell
me as meaningful output arrives.”

Choosing the wrong one creates noise or delay. Monitoring a quiet build gives
little benefit because there may be no useful line until completion. Treating a
watcher as a one-shot background job loses the reason you started it: its
ongoing output. Start from the decision you need to make, then choose the event
shape that supplies it.

## Events replace polling

The key mechanism is delivery. A background job's exit, or a monitor's line
events and stop event, waits for the parent delivery router. The runtime
forwards completion as a session message. If the parent is idle, that message
can begin a new turn; if it is busy, delivery waits for an appropriate turn
boundary. Monitor events waiting behind busy work can be coalesced per monitor,
so a backlog does not turn into an unbounded sequence of interruptions.

This is why “sleep, then poll” is a mistake. The job already has a notification
path. Polling consumes context and turns while adding no new source of truth.
The same principle applies to background subagents: under the background policy,
the parent keeps the task identifier, ends the turn once it has launched
non-overlapping work, and waits for the result message instead of repeatedly
querying task status. A subagent is finished only when it settles, not merely
when a child process first exits; the runtime may still perform follow-up work.

Event-driven waiting also makes ownership clear. The parent session receives the
information and chooses the response. A monitor never gives its command the
right to edit extra files, publish a result, or make a product decision.

## Inspect jobs in the workspace

Open the session's jobs inspector with:

```text
/gentle:jobs
```

It shows background jobs with running work first and newest jobs first within
each group. The view includes status, command, and output tail. On a narrow
terminal, `Tab` opens details. `s` stops the selected running job, and `q`
closes the modal. Completed jobs remain available for inspection there. The
footer shows `⧗ N jobs` while any job runs. In fullscreen at 140 columns or
wider, running jobs also get their own collapsible `⧗ Jobs` card in the rail,
one row per job with its elapsed time, newest first. Finished jobs stay on that
card for 60 seconds with their result (`✓` clean exit, `✗` failure, `–`
stopped), then the card clears itself. `ctrl+shift+j` or a click on the card's
header collapses it.

Those details are deliberately observability features. A command that has been
placed in the background should not become invisible. Before acting on a
completion, inspect the result: an exit notification says the process ended; it
does not by itself prove tests passed or the output means what you expected.

## Stop conditions and session boundaries

A session owns its jobs. On session shutdown, jobs do not outlive the session.
How a stop is reported depends on who stops the job: a job the agent stops with
`job_stop` sends no notice, while a job you stop from `/gentle:jobs` is reported
to the agent as stopped by the user. This prevents a forgotten command from later
appearing to be work performed by a different session. In the inspector, stopping
an active job is an explicit action rather than an implicit side effect of
closing the view.

Some execution contexts cannot receive a future result. The subagent runtime,
for example, rejects background subagents in single-shot modes such as `pi -p`
and `pi --mode json`, because those modes exit before a parent session can
receive the result. In those contexts, choose a mode that has a parent able to
receive events rather than assuming “background” is universally meaningful.

## Common mistakes

Do not use a shell `sleep` as a wait loop. Do not repeatedly poll job or
subagent status just because a task is queued or running. Do not launch the
same work again because it has not completed yet. And do not confuse a command's
completion with verification: interpret its exit result, then perform whatever
focused check the task requires.

Also avoid using a monitor as a substitute for a defined completion condition.
If no output line would change your decision, a monitor adds a stream you cannot
use. Conversely, do not hide a meaningful diagnostic stream behind a one-shot
wait when timely lines could guide the next step.

## Try it

Open `/gentle:jobs` and inspect the session without changing anything. Then
choose a familiar long-running command and answer two questions before you run
it in real work: would one completion result be sufficient, or would each output
line affect your next action? Choose `bash_background` for the first case and
`monitor` for the second. Finally, state what result you would need to inspect
before treating the work as successful.
