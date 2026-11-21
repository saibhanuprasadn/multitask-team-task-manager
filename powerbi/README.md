# Power BI dashboard — Multitask Team Task Manager

## Connect

1. Install **Power BI Desktop** and the **MySQL Connector/NET**
   (MySQL Installer → MySQL for Excel / Connector/NET).
2. Load the database first:
   `mysql -u root -p < sql/schema.sql`, then `sql/seed_data.sql`.
3. Run the AI script once (`ai/prioritize.py`) so `tasks.ai_priority`
   and `tasks.ai_reason` are filled in.
4. In Power BI Desktop: **Get Data → MySQL database**.
   Server: `localhost`, Database: `multitask`.
   Load the tables `tasks`, `users`, `projects`, `task_status_history`.
   (Or paste the queries from `sql/queries.sql` as native queries.)

## Model

- `tasks[assigned_to]` → `users[user_id]`
- `tasks[project_id]` → `projects[project_id]`
- `task_status_history[task_id]` → `tasks[task_id]`

## Measures (DAX)

```dax
Completion Rate =
DIVIDE(
    COUNTROWS(FILTER(tasks, tasks[status] = "Done")),
    COUNTROWS(tasks)
)

Overdue Tasks =
COUNTROWS(
    FILTER(tasks,
        tasks[status] <> "Done"
        && NOT ISBLANK(tasks[due_date])
        && tasks[due_date] < TODAY())
)

Open Tasks =
COUNTROWS(FILTER(tasks, tasks[status] <> "Done"))
```

## Visuals

| Visual | Shows |
|--------|-------|
| KPI cards | Open Tasks, Overdue Tasks, Completion Rate |
| Bar chart | Open tasks per member (from Q2) |
| Donut chart | Tasks by status (from Q4) |
| Table | Overdue tasks with AI priority and reason (from Q1) |
| Table | AI priority list — what to do first (from Q5) |
| Clustered column | Completion rate by project (from Q3) |

## Refresh

Refresh the dataset after `ai/prioritize.py` runs — the AI priorities
and reasons update in place, no rebuild needed.
