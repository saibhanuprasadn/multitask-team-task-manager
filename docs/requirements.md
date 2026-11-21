# Requirements — Multitask Team Task Manager

## Problem

Small teams lose track of who is doing what. Tasks live in chats and
spreadsheets, deadlines slip, and nobody can see who is overloaded until
work is already late.

## Goal

One shared place where a team creates projects, assigns tasks, tracks
status, and sees overdue work and workload at a glance — with AI
suggesting which task to pick up next.

## Users

| Role | Who | What they can do |
|------|-----|------------------|
| Admin | Team lead / manager | Create projects, create and assign tasks, change any task, view all reports |
| Member | Team member | View assigned tasks, update the status of their own tasks, view reports |

## User stories

- **US-01** — As an admin, I want to create a project so the team has one
  place for its work.
- **US-02** — As an admin, I want to create a task and assign it to a member
  with a due date, so ownership and deadlines are clear.
- **US-03** — As a member, I want to update the status of my task (To Do →
  In Progress → In Review → Done) so the team sees real progress.
- **US-04** — As an admin, I want to see overdue tasks in one list so I can
  follow up before work slips further.
- **US-05** — As an admin, I want to see each member's open-task workload so
  I stop overloading the same people.
- **US-06** — As an admin, I want a completion rate per project so I know
  how far along each project is.
- **US-07** — As a member, I want the system to suggest which of my tasks to
  do first, so I start with the most urgent work.
- **US-08** — As an admin, I want every status change recorded, so I can see
  the history of a task.

## Functional requirements

- **FR-01** — Create, read, update and delete projects.
- **FR-02** — Create tasks with title, description, project, assignee,
  status, priority and due date.
- **FR-03** — Only admins can create projects and assign tasks; members can
  only update the status of tasks assigned to them.
- **FR-04** — Task status follows the lifecycle To Do → In Progress →
  In Review → Done (see `process-flow.md`).
- **FR-05** — Every status change writes one row to `task_status_history`.
- **FR-06** — The dashboard shows overdue tasks, workload per member and
  completion rate per project (queries in `sql/queries.sql`).
- **FR-07** — `ai/prioritize.py` fills `ai_priority` and `ai_reason` for
  every open task.
- **FR-08** — A task with no due date is never counted as overdue.

## Non-functional requirements

- **NFR-01** — All data lives in MySQL; Power BI reads it live, no copies.
- **NFR-02** — The AI step must never block the dashboard: if the Gemini
  API fails, the rule-based scorer fills the priorities instead.
- **NFR-03** — No secrets in the repo: database password and Gemini API key
  come from `.env`, which is git-ignored.

## Out of scope

- Email or chat reminders (the dashboard shows overdue work instead).
- File attachments on tasks.
- Mobile app — the dashboard is the reporting view.
