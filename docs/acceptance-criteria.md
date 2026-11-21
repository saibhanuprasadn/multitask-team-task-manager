# Acceptance criteria & test cases

## Acceptance criteria

- **AC-01 (US-02)** — An admin can create a task with a title, project,
  assignee and due date; the task appears in To Do.
- **AC-02 (US-03)** — A member can move their own task To Do → In Progress
  → In Review → Done, and each move is recorded in `task_status_history`.
- **AC-03 (US-03)** — A member cannot change the status of a task assigned
  to someone else.
- **AC-04 (US-04)** — The overdue list shows only open tasks whose due date
  is before today; tasks without a due date never appear.
- **AC-05 (US-05)** — Workload counts only open tasks (Done tasks are
  excluded).
- **AC-06 (US-06)** — Completion rate = Done tasks ÷ all tasks in the
  project, shown as a percentage.
- **AC-07 (US-07)** — Every open task gets an `ai_priority` (High / Medium /
  Low) and a one-line `ai_reason` after `prioritize.py` runs.
- **AC-08 (US-07)** — If the Gemini API fails, priorities are still filled
  by the rule-based scorer — the run never leaves tasks blank.

## Test cases

| ID | Covers | Steps | Expected result |
|----|--------|-------|-----------------|
| TC-01 | AC-01 | Admin creates a task with title, project, assignee, due date | Task exists in `tasks` with status To Do |
| TC-02 | AC-02 | Member moves own task to In Progress, then In Review, then Done | Each move adds one row to `task_status_history` |
| TC-03 | AC-03 | Member tries to move a task assigned to someone else | Change is rejected |
| TC-04 | AC-04 | Run the overdue query with tasks due yesterday, today, tomorrow, and no due date | Only the yesterday task is listed |
| TC-05 | AC-05 | Count open tasks per member with 1 Done task among them | Done task is not counted |
| TC-06 | AC-06 | Project with 3 Done out of 12 tasks | Completion rate shows 25% |
| TC-07 | AC-07 | Run `python prioritize.py` | Every open task has `ai_priority` and `ai_reason` filled |
| TC-08 | AC-08 | Run `python prioritize.py` with no API key set | Priorities are filled by the rule-based scorer |
| TC-09 | AC-04 | Task with no due date | Never appears in the overdue list |
| TC-10 | AC-02 | Move a task In Review → In Progress | Allowed; history row records the move |

Run TC-04 to TC-06 against the seeded database (`sql/seed_data.sql`):
overdue = 3 tasks, completion = 25% overall (3 of 12 Done).
