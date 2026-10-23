---
title: "Welcome"
slug: welcome
description: "Meet Gentle Shell School and how each lesson starts from a prompt you paste into gentle-shell."
order: 1
module: "Getting started"
quiz: false
agent_instructions: |
  Welcome the student and explain how the course works in two or three
  sentences: each lesson page has a prompt; they paste it into gentle-shell; you
  teach that lesson, check their real setup, record it, and hand back the next
  lesson's prompt. Their open lesson page updates by itself when you record a
  lesson. The language comes from the llms.txt in the prompt.

  If the prompt has no student ID, mention that the Enroll button on the
  website's home page keeps their place, and that the lesson prompts then
  include the ID. Never enroll them yourself.

  Then run `gentle-shell --version`. If it prints version information, you are
  already running in gentle-shell, so the two setup lessons are done: record
  `welcome`, `install-gentle-shell`, and `open-gentle-shell` with PUT
  {origin}/api/progress/{studentId} using `source: "agent"` (when there is an
  ID), and hand back the `next.prompt` of `open-gentle-shell` (GET
  {origin}/api/lessons/open-gentle-shell?locale=<locale>), which starts lesson 04.
  If it fails, record only `welcome` and send them to the Install Gentle Shell
  lesson page on the website. When something in a lesson is wrong, follow the
  Reporting problems section of llms.txt.
---

Welcome to **Gentle Shell School**, a free, self-paced course for learning
gentle-shell: the coding-agent harness built on Pi.

## How this course works

Every lesson works the same way:

1. **Read the lesson here**, on the website.
2. **Copy the prompt** at the top of the lesson page and paste it into
   gentle-shell.
3. **Your agent teaches that lesson.** It explains the topic, asks quiz
   questions where appropriate, and checks your real setup before it records
   the lesson as complete.
4. **It hands you the next prompt.** Paste it to continue, here or in a new
   session. Your lesson page shows the same prompt.

The prompt carries everything the agent needs: which lesson to teach, where the
course instructions live, and, once you enroll, your anonymous student ID.

## Keep your place

Enroll with the button on the home page. You get an anonymous student ID: no
account and no login. From then on every lesson prompt includes it, your agent
records completed lessons with it, and this site shows your progress, updating
by itself while the page is open.

## Your language

The course follows the language you are reading. Use the language switcher at
the top of the site: the prompts then point your agent at the instructions for
that language, so it teaches you in it without asking.

## Not using gentle-shell yet?

Read the next two lessons here first. **Install Gentle Shell** gets the
`gentle-shell` command working, and **Open Gentle Shell** starts it and shows
you where to paste your first prompt.

Found a problem? Your agent can report it as a GitHub issue with your consent,
or use the "Report a problem" link.
