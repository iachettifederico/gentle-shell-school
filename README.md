# Gentle Shell School

A free, self-paced course for learning gentle-shell, in the style of
[opencode.school](https://github.com/agentschools/opencode.school).

Every lesson has two readers: the student, on the website, and the student's
agent, through a JSON API. The agent teaches the lesson, quizzes the student,
and verifies their real setup.

## Run it

```sh
bin/setup --skip-server   # bundle + db:prepare (bin/dev is not shipped)
make server               # Puma on :3000; also watches Tailwind in development
bin/rspec
bin/ci         # lint, security audits, tests
```

## Demo course (local only)

Run the tiny demo course in development with:

```sh
COURSE=demo make server
```

It contains three short lessons: how the course works, a quiz with a
`gentle-shell --version` setup check, and a no-submit practice of the feedback
consent flow. `COURSE=demo` is ignored outside development, so test and
production always serve the real course.

To compare the original course on `main` with the improved course on
`feat/phase-6-gentle-native`, check out each branch in turn and start it with
`COURSE=demo make server`. The same local demo lessons make the course behavior
comparable without affecting either production course.

## How a student takes the course

There is one path. Each lesson page shows a prompt; the student copies it into
gentle-shell, and the agent teaches that lesson and hands back the next prompt:

```text
I'm enrolled in Gentle Shell School as <id>. Let's do the "<title>" lesson (<slug>). Fetch https://<host>/es-AR/llms.txt for instructions.
```

- The site builds the prompt (`LessonPrompt`); once the student enrolls with the
  site's Enroll button, the browser fills in their anonymous student ID.
- The language comes from the llms.txt address (`/llms.txt`, `/es/llms.txt`,
  `/es-AR/llms.txt`); the agent never asks for it.
- The lessons API returns each lesson's `next` lesson with the same prompt and
  page URL; a `?sid=<id>` link opens it in the browser with the student's ID.
- While a student ID is present, the open page polls progress every two seconds
  (paused when the tab is hidden), so completions the agent records show up live.

No package or `/school` command is needed.

## Labs

Hands-on labs live in `content/labs/<slug>/`. Each `lab.yml` links one lesson,
contains a Markdown brief, a `node --test` check, and independent-grader rubric
items; `starter/` is the complete scratch-project payload served by the API.
Every starter intentionally fails its check until the student completes it.
Reference solutions stay in `spec/fixtures/labs/` and are never served.

`COURSE=demo` also selects `content/demo/labs/` in development. Agents fetch a
lab from `GET /api/labs/:slug`, write its files into a student-chosen scratch
directory, run its check, coach with `monitor`, and grade against its rubric.

## Writing a lesson

Lessons are Markdown files in `content/lessons/`, not database rows. The file
name prefix (`01-`, `02-`) is for humans; ordering comes from `order`, and
routing uses `slug`.

```markdown
---
title: "Welcome"              # sentence case
slug: welcome                 # lowercase kebab-case, unique
description: "Meet the course."
order: 1                      # positive integer, unique
quiz: false                   # true appends the shared quiz instructions
agent_instructions: |
  What "done" looks like and how the agent verifies it.
---

Lesson body in GitHub-flavored Markdown. Raw HTML is escaped.
```

- `{origin}` in `agent_instructions` or the body is replaced with the serving
  origin, for example `{origin}/llms.txt`.
- Quiz lessons list their topics in `agent_instructions`; the shared quiz
  instructions (`Course::QuizInstructions`) are appended at serve time.
- A malformed lesson (missing or unknown keys, bad YAML, duplicate slug or
  order) raises `Course::InvalidLesson` naming the file. `spec/content` checks
  every shipped lesson.

## Agent-facing endpoints

| Endpoint | Returns |
| --- | --- |
| `GET /llms.txt`, `/es/llms.txt`, `/es-AR/llms.txt` | Plain-text teaching instructions for agents, in that language |
| `GET /api/openapi.json` | OpenAPI 3.1 description of the API (`config/openapi.yml`) |
| `GET /api/lessons` | All lessons, sorted by `order`, including a nullable `lab` slug |
| `GET /api/labs` | Lab summaries (`slug`, lesson, title) |
| `GET /api/labs/:slug` | A lab's brief, check, rubric, and starter files |
| `GET /api/lessons/:slug` | One lesson, or 404 `{"error":"Lesson not found"}` |
| `POST /api/enroll` | Anonymous student ID and empty progress (the site's Enroll button) |
| `GET /api/progress/:student_id` | A student's progress |
| `PUT /api/progress/:student_id` | Mark a lesson complete |
| `DELETE /api/progress/:student_id` | Undo one completion or reset all completions |
| `GET /api/instructions/:student_id` | Plain-text student-specific agent instructions |

Lessons are serialized as `{order, slug, title, description, module, lab, locale, agentInstructions, content, url, next}`, where `next` is `{slug, title, url, prompt}` or `null`. Progress is serialized as `{completedLessons, createdAt, updatedAt}`; enroll first and retain the returned anonymous `studentId` to read or update it.
API responses allow any origin (CORS) and need no authentication.

When you add or change an endpoint, update `config/openapi.yml` and
`app/views/llms/show.text.erb` in the same commit.

## Feedback

Report a wrong or outdated fact, broken setup check, confusing explanation,
typo, site/API bug, or suggestion with the website's **Report a problem** link.
Agents must follow the `Reporting problems` section in `/llms.txt`: obtain the
student's explicit consent, search for duplicates, and exclude private data.

## Architecture

The app follows the layers in `AGENTS.md` and `docs/engineering/`:

- `app/domain/course` — `Lesson`, `LessonContent`, `Catalog`: invariants and
  agent-instruction policy, free of Rails.
- `app/adapters` — `Course::FileLessonRepository` (Markdown + frontmatter) and
  `MarkdownRenderer` (commonmarker).
- `app/systems/course/lessons_system.rb` — the entry point controllers use.
