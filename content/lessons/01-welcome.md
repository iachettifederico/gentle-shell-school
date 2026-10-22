---
title: "Welcome"
slug: welcome
description: "Meet Gentle Shell School and how any coding agent can start your course."
order: 1
module: "Getting started"
quiz: false
agent_instructions: |
  Welcome the student and explain that any coding agent can begin the course.
  Start with the voluntary enrollment handshake in {origin}/llms.txt: create an
  enrollment link, let the student choose whether to use it, then check its
  status before tracking progress. If they decline, teach without tracking.
  If you are not gentle-shell, teach lessons `install-gentle-shell` and
  `open-gentle-shell` next; they install Gentle Shell and hand the student's
  anonymous student ID to it. If you are gentle-shell, follow the conditional
  instructions in `install-gentle-shell`, which verify that fact and skip both
  setup lessons; then mention that the packaged course tutor is installed with
  `pi install git:github.com/iachettifederico/gentle-shell-school` and started
  with `/school`. Course lessons are listed at {origin}/api/lessons. When
  something in a lesson is wrong, follow the Reporting problems section of
  {origin}/llms.txt.
---

Welcome to **Gentle Shell School**, a free, self-paced course for learning
gentle-shell: the coding-agent harness built on Pi.

## How this course works

Every lesson has two audiences:

- **You** read the lesson here, on the website.
- **Your agent** reads the same lesson through the course API. Each lesson
  includes instructions telling the agent what "done" looks like and how to
  check it.

Any coding agent can start the course. It explains each topic, asks quiz
questions where appropriate, and verifies your real setup before marking a
lesson complete. If that first agent is not gentle-shell, the next two lessons
help you install and open Gentle Shell, then transfer your course progress to
its agent.

Already using gentle-shell? Install the course tutor package, restart Pi, then
use `/school` to begin or continue the course:

```sh
pi install git:github.com/iachettifederico/gentle-shell-school
```

Found a problem? Your agent can report it as a GitHub issue with your consent,
or use the "Report a problem" link.

## Start the course

Ask any coding agent:

```text
Read {origin}/llms.txt and start the course.
```
