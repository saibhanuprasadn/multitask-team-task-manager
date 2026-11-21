-- Multitask — Team Task Manager
-- Reporting queries for the Power BI dashboard.
-- Run:  mysql -u root -p multitask < queries.sql

USE multitask;

-- Q1. Overdue tasks: open tasks with a due date before today.
--     Tasks with no due date never appear here.
SELECT t.task_id, t.title, u.full_name AS assigned_to,
       p.project_name, t.due_date, t.priority, t.ai_priority
FROM tasks t
JOIN users u ON u.user_id = t.assigned_to
JOIN projects p ON p.project_id = t.project_id
WHERE t.status <> 'Done'
  AND t.due_date IS NOT NULL
  AND t.due_date < CURDATE()
ORDER BY t.due_date;

-- Q2. Workload per member: open tasks and overdue tasks each.
SELECT u.full_name AS member,
       COUNT(t.task_id) AS open_tasks,
       SUM(CASE WHEN t.due_date < CURDATE() THEN 1 ELSE 0 END) AS overdue_tasks
FROM users u
LEFT JOIN tasks t
  ON t.assigned_to = u.user_id AND t.status <> 'Done'
GROUP BY u.user_id, u.full_name
ORDER BY open_tasks DESC;

-- Q3. Completion rate by project.
SELECT p.project_name,
       COUNT(t.task_id) AS total_tasks,
       SUM(CASE WHEN t.status = 'Done' THEN 1 ELSE 0 END) AS done_tasks,
       ROUND(100.0 * SUM(CASE WHEN t.status = 'Done' THEN 1 ELSE 0 END)
             / COUNT(t.task_id), 1) AS completion_pct
FROM projects p
JOIN tasks t ON t.project_id = p.project_id
GROUP BY p.project_id, p.project_name;

-- Q4. Tasks by status.
SELECT status, COUNT(*) AS task_count
FROM tasks
GROUP BY status;

-- Q5. AI priority list: open tasks ordered by suggested priority, then due date.
SELECT t.task_id, t.title, u.full_name AS assigned_to,
       t.due_date, t.priority, t.ai_priority, t.ai_reason
FROM tasks t
LEFT JOIN users u ON u.user_id = t.assigned_to
WHERE t.status <> 'Done'
ORDER BY FIELD(COALESCE(t.ai_priority, t.priority), 'High', 'Medium', 'Low'),
         t.due_date;
