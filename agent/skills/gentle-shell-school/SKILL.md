---
name: gentle-shell-school
description: "Trigger: school, course, lesson, tutor, gentle-shell school. Teach and verify the Gentle Shell School course."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Activation Contract

Use for `/school`, a course lesson, or Gentle Shell School tutoring. Do not use it for unrelated help.

## Hard Rules

- Treat the supplied URL as the origin; otherwise ask once. Keep it only in this conversation and, when available, Engram—never `~/.gentle-shell-school`.
- Read `<origin>/llms.txt` before acting. Follow its **Reporting problems** rules exactly.
- Enroll with `POST <origin>/api/enroll`; retain the anonymous `studentId` in the conversation. Read student instructions and use `GET /api/progress/:studentId` to continue.
- Never mark a lesson complete without observed evidence.

## Decision Gates

| Situation | Action |
| --- | --- |
| Memory tools absent | Continue without memory or notice. |
| Fresh read-only subagent unavailable | Grade the lab yourself and use `verifiedBy: "self"`. |
| Native review available and enabled | Use it for the capstone. |
| Native review unavailable or disabled | Run the Judgment Day skill as the capstone's final exam. |

## Execution Steps

1. At session start, search Engram topic `gentle-shell-school/<lesson-slug>/gaps`; ask at most two spaced-review questions from it. Save observed struggles there after the lesson.
2. Fetch the requested lesson, or start the first incomplete lesson. Teach its content, run its setup check, quiz with `ask_user_question`, then summarize and offer the next lesson.
3. Record a passing setup check with `PUT /api/progress/:studentId` using exactly `{"lessonSlug":"<slug>","source":"agent","model":"<model>","evidence":{"checks":[{"command":"<command>","result":"pass","summary":"<observed result>"}],"verifiedBy":"self"}}`.
4. For a lesson lab, fetch `GET /api/labs/:slug`; ask the student to choose a new scratch directory, write only its `files` starter content there, and run `check` from that directory. Use `monitor` while the check runs and coach from its output. Launch a fresh-context, read-only verifier when available; give it only the lab brief, rubric, check output, and file paths. Record its grade with the same evidence shape and `verifiedBy: "independent-verifier"`; otherwise grade yourself with `"self"`.
5. For study-partner work, have the student name their work-session subject with `orchestrator_session_id`; use `orchestrator_list` and metadata `orchestrator_consult` to follow published progress. Ask for documented model-cost permission before a reasoning consult.
6. For the capstone, check `gentle-ai review mode status`; use native review only when available and enabled, otherwise load the Judgment Day skill for the final exam.

## Output Contract

State the lesson, observed checks, completion evidence, review route, and any unavailable capability.

## References

- [School prompt](../../prompts/school.md)
