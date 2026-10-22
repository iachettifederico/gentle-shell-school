---
title: "Open Gentle Shell"
slug: open-gentle-shell
description: "Start Gentle Shell and hand your course progress to its tutoring agent."
order: 3
module: "Getting started"
quiz: true
agent_instructions: |
  If you already established in lesson `install-gentle-shell` that you are
  gentle-shell, do not teach this lesson: that lesson records both conditional
  lessons and continues with lesson 04.

  Otherwise, teach the student to start Gentle Shell with `gentle-shell` and
  to give its agent the prepared hand-off prompt below. Before the student
  leaves this conversation, record completion of `open-gentle-shell` with PUT
  {origin}/api/progress/{studentId}, using `source: "agent"`, and tell them
  that you recorded it. The anonymous student ID is what lets the new agent
  continue their progress.

  Ask these questions with ask_user_question, including the correct answer:
  1. Which command opens Gentle Shell after it is installed?
     Correct answer: `gentle-shell`.
  2. What must the hand-off prompt include so progress follows the student?
     Correct answer: The Gentle Shell School student ID.
  3. Which agent records this lesson before the hand-off?
     Correct answer: The agent teaching this lesson now.

  The real-setup check, which you can observe here, is that `gentle-shell
  --version` prints a version and the student has the exact prepared hand-off
  prompt with their own student ID ready to paste. The lesson is done when you
  have recorded completion and given the student that prompt. You cannot see the
  new session: the gentle-shell agent that receives the prompt confirms the
  student ID with GET {origin}/api/progress/{studentId} and continues with
  lesson 04.
---

# Open Gentle Shell

You have confirmed that the `gentle-shell` launcher is available. Now open it
and give its agent the one piece of information that carries your course forward:
your anonymous Gentle Shell School student ID. The ID is not an account or a
login. It is the course's progress key, so the new tutoring agent can read what
you have already completed.

## Start the workspace

In a terminal, run:

```bash
gentle-shell
```

That opens Pi with the Gentle Shell package loaded. The launcher normally uses
its own isolated agent home, so it can set up its workspace without editing an
existing Pi agent. Wait until the interactive session is ready before pasting
the hand-off prompt.

## Carry your progress forward

Your current tutor should already know your student ID from enrolling you. Ask
it to show you the ID if you do not have it. Before you leave this conversation,
it records this lesson as complete. Then paste this prompt into the new Gentle
Shell session, replacing `<id>` with your actual student ID:

```text
Read {origin}/llms.txt. My Gentle Shell School student ID is <id>. Continue the course.
```

The prompt gives the new agent both the course instructions and your progress
key. It should read the course instructions, use that ID when it requests your
student-specific instructions, and continue at the next incomplete lesson.

## Why the order matters

Do not rely on the new agent to guess what happened in this conversation. The
previous agent records this lesson *before* the hand-off, using the course API
with `source: "agent"`. That makes the progress record independent of either
agent's chat history. If you close a terminal, switch models, or resume later,
the same ID still identifies the same course progress.

If the command does not start Gentle Shell, return to **Install Gentle Shell**
and re-run its version check. If Gentle Shell opens but the new agent does not
continue correctly, paste the hand-off prompt again with the same ID rather than
creating a new enrollment.

## Try it

Have your current agent confirm that it recorded this lesson. Open
`gentle-shell`, paste the prepared prompt with your ID, and let the new agent
continue with **The Layers of Gentle Shell**.
