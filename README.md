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
| `GET /llms.txt` | Plain-text overview and operating instructions for agents |
| `GET /api/openapi.json` | OpenAPI 3.1 description of the API (`config/openapi.yml`) |
| `GET /api/lessons` | All lessons, sorted by `order` |
| `GET /api/lessons/:slug` | One lesson, or 404 `{"error":"Lesson not found"}` |
| `POST /api/enroll` | Anonymous student ID and empty progress |
| `GET /api/progress/:student_id` | A student's progress |
| `PUT /api/progress/:student_id` | Mark a lesson complete |
| `DELETE /api/progress/:student_id` | Undo one completion or reset all completions |
| `GET /api/instructions/:student_id` | Plain-text student-specific agent instructions |

Lessons are serialized as `{order, slug, title, description, agentInstructions, content}`. Progress is serialized as `{completedLessons, createdAt, updatedAt}`; enroll first and retain the returned anonymous `studentId` to read or update it.
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
