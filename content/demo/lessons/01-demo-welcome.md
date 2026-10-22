---
title: "Demo welcome"
slug: demo-welcome
description: "Try the Gentle Shell School lesson flow locally."
order: 1
module: "Demo"
quiz: false
agent_instructions: |
  This is a local demo course. Explain that the student reads each lesson on
  the website while their agent uses the course API as a tutor. Describe the
  lesson loop: read, discuss, complete any quiz or setup check, and continue.
  Confirm that this demo is safe to explore locally and ask whether they want
  to open the next demo lesson. Course lessons are listed at {origin}/api/lessons.
---

# Welcome to the local demo course

This tiny course lets you try Gentle Shell School without working through the
full curriculum. It runs only on your local development server, so it is a
useful place to see how the website, lesson API, and agent instructions fit
together.

Each lesson has two readers. You read the page in your browser. Your agent can
read the same lesson through the API and use its instructions to guide you.
That makes the agent a tutor: it can explain the material, ask a quiz question
when a lesson has one, and confirm a real setup check before you move on.

For this demo, nothing changes your course installation or files. Read a
lesson, talk through it with your agent, and choose when to continue. The next
lesson includes a short quiz and a harmless command check. The last lesson
practices the consent step for reporting a problem without filing anything.

This is a **local demo course**, not the full Gentle Shell School curriculum.
