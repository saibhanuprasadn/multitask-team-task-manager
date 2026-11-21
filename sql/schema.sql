-- Multitask — Team Task Manager
-- MySQL 8 schema. Run:  mysql -u root -p < schema.sql

CREATE DATABASE IF NOT EXISTS multitask;
USE multitask;

CREATE TABLE users (
    user_id    INT AUTO_INCREMENT PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    role       VARCHAR(20) NOT NULL DEFAULT 'member'
               CHECK (role IN ('admin', 'member')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE projects (
    project_id   INT AUTO_INCREMENT PRIMARY KEY,
    project_name VARCHAR(150) NOT NULL,
    description  TEXT,
    owner_id     INT NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users (user_id)
);

CREATE TABLE tasks (
    task_id      INT AUTO_INCREMENT PRIMARY KEY,
    project_id   INT NOT NULL,
    title        VARCHAR(200) NOT NULL,
    description  TEXT,
    assigned_to  INT,
    status       VARCHAR(20) NOT NULL DEFAULT 'To Do'
                 CHECK (status IN ('To Do', 'In Progress', 'In Review', 'Done')),
    priority     VARCHAR(10) NOT NULL DEFAULT 'Medium'
                 CHECK (priority IN ('Low', 'Medium', 'High')),
    ai_priority  VARCHAR(10)
                 CHECK (ai_priority IN ('Low', 'Medium', 'High')),
    ai_reason    VARCHAR(500),
    due_date     DATE,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects (project_id),
    FOREIGN KEY (assigned_to) REFERENCES users (user_id)
);

CREATE TABLE task_status_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    task_id    INT NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_by INT,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES tasks (task_id),
    FOREIGN KEY (changed_by) REFERENCES users (user_id)
);
