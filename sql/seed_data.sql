-- Multitask — Team Task Manager
-- Sample data. Dates are relative to today (CURDATE) so the overdue
-- tasks stay overdue whenever the seed is loaded.
-- Run:  mysql -u root -p < seed_data.sql

USE multitask;

INSERT INTO users (full_name, email, role) VALUES
    ('Ananya Sharma', 'ananya@multitask.local', 'admin'),
    ('Rahul Verma',    'rahul@multitask.local',  'member'),
    ('Priya Nair',     'priya@multitask.local',  'member'),
    ('Arjun Mehta',    'arjun@multitask.local',  'member');

INSERT INTO projects (project_name, description, owner_id) VALUES
    ('Website Redesign', 'Redesign the company website', 1),
    ('Mobile App Launch', 'Launch the customer mobile app', 1);

-- 12 tasks: 3 Done, 3 overdue, 1 due today, rest upcoming.
INSERT INTO tasks (project_id, title, description, assigned_to, status, priority, due_date) VALUES
    (1, 'Design homepage wireframes', 'Wireframes for the new homepage', 3, 'In Progress', 'High',   CURDATE() - INTERVAL 2 DAY),
    (1, 'Write homepage copy', 'Final copy for homepage sections', 2, 'To Do', 'Medium', CURDATE() + INTERVAL 1 DAY),
    (1, 'Set up staging environment', 'Staging server for the redesign', 4, 'Done', 'Medium', CURDATE() - INTERVAL 5 DAY),
    (1, 'Review accessibility checklist', 'WCAG checklist for new pages', 3, 'In Review', 'Low', CURDATE() + INTERVAL 3 DAY),
    (1, 'Fix broken links on blog', 'Audit and fix blog links', 2, 'To Do', 'High', CURDATE() - INTERVAL 1 DAY),
    (1, 'Update sitemap', 'Regenerate sitemap after restructure', 4, 'Done', 'Low', CURDATE() - INTERVAL 3 DAY),
    (2, 'Create app store screenshots', 'Screenshots for Play Store listing', 3, 'In Progress', 'High', CURDATE() + INTERVAL 2 DAY),
    (2, 'Test login flow on Android', 'End-to-end login test on Android', 4, 'In Progress', 'Medium', CURDATE() - INTERVAL 4 DAY),
    (2, 'Write release notes', 'Release notes for v1.0', 2, 'To Do', 'Low', CURDATE() + INTERVAL 6 DAY),
    (2, 'Set up crash reporting', 'Crash reporting for the app', 4, 'Done', 'High', CURDATE() - INTERVAL 7 DAY),
    (2, 'Review push notification copy', 'Review copy for launch notifications', 3, 'To Do', 'Medium', CURDATE()),
    (2, 'Final QA pass', 'Full QA pass before launch', 2, 'In Review', 'High', CURDATE() + INTERVAL 4 DAY);

INSERT INTO task_status_history (task_id, old_status, new_status, changed_by) VALUES
    (1, 'To Do', 'In Progress', 3),
    (3, 'To Do', 'In Progress', 4),
    (3, 'In Progress', 'Done', 4),
    (8, 'To Do', 'In Progress', 4);
