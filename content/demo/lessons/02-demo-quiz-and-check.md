---
title: "Quiz and setup check"
slug: demo-quiz-and-check
description: "Try a quiz and confirm your local gentle-shell command."
order: 2
module: "Demo"
quiz: true
agent_instructions: |
  This is a local demo course. Ask the student: "What command prints the
  installed gentle-shell version?" The expected answer is `gentle-shell
  --version`. Then ask the student to run `gentle-shell --version` in their
  terminal. Confirm that its output includes a version string before treating
  the setup check as complete. Course lessons are listed at {origin}/api/lessons.
---

# Try a quiz and a real check

This local demo course now shows the two kinds of interaction that make a
lesson active. First, your agent asks a short question. Use it as a
conversation: answer in your own words, and ask for an explanation if the
answer is unclear. The question for this lesson is about the command that
prints the installed gentle-shell version.

Next comes a real setup check. In a terminal, run:

```sh
gentle-shell --version
```

A successful check prints a version string. Your agent should wait for you to
run the command and confirm that output, rather than assuming your setup is
ready. If the command does not print a version, pause here and investigate
with your agent.

The check only reads the installed program version; it does not change your
machine. This is a **local demo course**, so you can safely repeat the quiz
and command while exploring how tutoring works.
