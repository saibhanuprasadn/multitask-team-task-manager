# Multitask — Team Task Manager

A team task management system, built the way a Business Analyst would:
requirements first, then data, then a dashboard — with AI helping decide
what to work on next.

- **Requirements & user stories** — see `docs/requirements.md`
- **Task lifecycle & process flow** — see `docs/process-flow.md`
- **Acceptance criteria & test cases** — see `docs/acceptance-criteria.md`
- **MySQL database** — schema, sample data and reporting queries in `sql/`
- **Power BI dashboard** — connect Power BI Desktop to the MySQL database
  (guide in `powerbi/README.md`): overdue tasks, workload per member,
  completion rate by project, and AI-priority list
- **AI priority suggestions** — `ai/prioritize.py` uses the Gemini API to
  suggest a priority (High / Medium / Low) for every open task, with a
  rule-based fallback when the API is unavailable

## Quick start

### 1. Database (MySQL 8)

```sql
mysql -u root -p < sql/schema.sql
mysql -u root -p < sql/seed_data.sql
```

### 2. Power BI dashboard

Follow `powerbi/README.md`: connect Power BI Desktop to MySQL, load the
`tasks`, `users`, `projects` and `task_status_history` tables, add the
measures, and build the visuals. Run the AI script first so the
`ai_priority` column is filled in.

### 3. AI priority suggestions

```bash
cd ai
pip install -r requirements.txt
cp .env.example .env   # fill in your MySQL details and Gemini API key
python prioritize.py
```

Dry run (no database, no API key — shows what it would do):

```bash
python prioritize.py --dry-run
```

## How it works

1. Admins create projects and assign tasks; members update task status.
2. Every status change is recorded in `task_status_history`.
3. `ai/prioritize.py` reads the open tasks and asks Gemini to suggest a
   priority from the deadline, the task description, and the assignee's
   current workload. If the API call fails, a rule-based scorer takes over
   (overdue → High, due within 2 days → High, within 7 days → Medium).
4. Power BI reads the same tables and shows overdue work, who is loaded,
   and how much of each project is done.

## Tech

MySQL 8 · SQL · Power BI · Python · Gemini API

## Author

Sai Bhanu Prasad Narra — B.Tech Computer Science, 2026.
