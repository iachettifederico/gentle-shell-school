---
title: "Welcome"
slug: welcome
description: "Meet Gentle Shell School and how your agent will teach you."
order: 1
module: "Getting started"
quiz: false
agent_instructions: |
  This lesson is complete once the student is talking to you through
  gentle-shell and has read how the course works.

  Confirm you are running inside gentle-shell, briefly explain that you
  will teach each lesson, quiz them, and check their real setup, then ask
  whether they want to continue to the next lesson. Course lessons are
  listed at {origin}/api/lessons. When something in a lesson is wrong, follow
  the Reporting problems section of {origin}/llms.txt.
---

Welcome to **Gentle Shell School**, a free, self-paced course for learning
gentle-shell: the coding-agent harness built on Pi.

## How this course works

Every lesson has two audiences:

- **You** read the lesson here, on the website.
- **Your agent** reads the same lesson through the course API. Each lesson
  includes instructions telling the agent what "done" looks like and how to
  check it.

So the agent running in your terminal becomes your tutor. It explains each
topic, asks you a few quiz questions, and verifies your real setup before
marking the lesson complete.

Found a problem? Your agent can report it as a GitHub issue with your consent, or use the "Report a problem" link.

## Start the course

Open gentle-shell and ask it:

```text
Read {origin}/llms.txt and start the Welcome lesson.
```
