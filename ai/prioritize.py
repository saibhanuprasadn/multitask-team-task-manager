#!/usr/bin/env python3
"""Multitask — AI priority suggestions.

Reads the open tasks from MySQL, asks Gemini to suggest a priority
(High / Medium / Low) with a one-line reason for each, and writes the
result back to tasks.ai_priority / tasks.ai_reason.

If the Gemini API is unavailable (no key, quota, 503), a rule-based
scorer fills the priorities instead, so the run never leaves tasks blank.

Usage:
    python prioritize.py            # full run against MySQL
    python prioritize.py --dry-run  # no database, no API key
    python prioritize.py --limit 5  # only the first 5 open tasks

Config comes from .env (see .env.example). Never commit .env.
"""
import argparse
import json
import os
import sys
from datetime import date

from dotenv import load_dotenv

MODELS = ["gemini-3.8-flash", "gemini-2.5-flash"]  # first that answers wins


# ---------------------------------------------------------------- rules
def rule_priority(task, open_count):
    """Rule-based fallback. Returns (priority, reason)."""
    due = task.get("due_date")
    today = date.today()
    if due is not None and due < today:
        priority, why = "High", "Overdue"
    elif due is not None and (due - today).days <= 2:
        priority, why = "High", "Due within 2 days"
    elif due is not None and (due - today).days <= 7:
        priority, why = "Medium", "Due within 7 days"
    else:
        priority, why = "Low", "No urgent deadline"
    if open_count >= 4:
        why += "; assignee has %d open tasks" % open_count
    return priority, why


SAMPLE_TASKS = [
    {"task_id": 1, "title": "Design homepage wireframes",
     "description": "Wireframes for the new homepage",
     "due_date": date.today().fromordinal(date.today().toordinal() - 2),
     "status": "In Progress", "assignee": "Priya Nair", "open_count": 4},
    {"task_id": 2, "title": "Write homepage copy",
     "description": "Final copy for homepage sections",
     "due_date": date.today().fromordinal(date.today().toordinal() + 1),
     "status": "To Do", "assignee": "Rahul Verma", "open_count": 4},
    {"task_id": 9, "title": "Write release notes",
     "description": "Release notes for v1.0",
     "due_date": date.today().fromordinal(date.today().toordinal() + 6),
     "status": "To Do", "assignee": "Rahul Verma", "open_count": 4},
]


def build_prompt(tasks):
    lines = [
        "You are helping a team lead prioritise open tasks.",
        "For each task, suggest a priority: High, Medium or Low, with a short reason.",
        "Consider the due date, the task description, and how many open tasks the assignee already has.",
        "Reply with JSON only, a list like:",
        '[{"task_id": 1, "priority": "High", "reason": "Overdue by 2 days"}]',
        "",
        "Tasks:",
    ]
    for t in tasks:
        lines.append(
            "- task_id %s: %s | %s | due %s | status %s | assignee %s (%d open tasks)"
            % (t["task_id"], t["title"], t.get("description") or "",
               t.get("due_date"), t.get("status"), t.get("assignee"),
               t.get("open_count", 0))
        )
    return "\n".join(lines)


def ask_gemini(api_key, tasks):
    """Call Gemini; try each model in turn. Returns {task_id: (priority, reason)}."""
    from google import genai

    client = genai.Client(api_key=api_key)
    prompt = build_prompt(tasks)
    last_error = None
    for model in MODELS:
        try:
            response = client.models.generate_content(model=model, contents=prompt)
            text = response.text.strip()
            if text.startswith("```"):
                text = text.strip("`").split("\n", 1)[1].rsplit("```", 1)[0]
            out = {}
            for item in json.loads(text):
                out[int(item["task_id"])] = (item["priority"], item["reason"])
            return out
        except Exception as exc:  # noqa: BLE001 - fall through to the next model
            last_error = exc
    raise RuntimeError("Gemini call failed for all models: %s" % last_error)


# ---------------------------------------------------------------- database
def load_tasks(conn):
    cur = conn.cursor(dictionary=True)
    cur.execute(
        "SELECT t.task_id, t.title, t.description, t.due_date, t.status,"
        "       u.full_name AS assignee"
        "  FROM tasks t LEFT JOIN users u ON u.user_id = t.assigned_to"
        " WHERE t.status <> 'Done' ORDER BY t.due_date"
    )
    tasks = cur.fetchall()
    # open-task count per assignee (used by the rule-based scorer)
    cur.execute(
        "SELECT u.full_name, COUNT(t.task_id) AS n"
        "  FROM users u LEFT JOIN tasks t"
        "    ON t.assigned_to = u.user_id AND t.status <> 'Done'"
        " GROUP BY u.user_id"
    )
    for row in cur.fetchall():
        for t in tasks:
            if t["assignee"] == row["full_name"]:
                t["open_count"] = row["n"]
    cur.close()
    return tasks


def save_priorities(conn, results):
    cur = conn.cursor()
    for task_id, (priority, reason) in results.items():
        cur.execute(
            "UPDATE tasks SET ai_priority = %s, ai_reason = %s WHERE task_id = %s",
            (priority, reason[:500], task_id),
        )
    conn.commit()
    cur.close()


# ---------------------------------------------------------------- main
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true",
                        help="use sample tasks; no database, no API key")
    parser.add_argument("--limit", type=int, default=0,
                        help="only process the first N open tasks")
    args = parser.parse_args()
    load_dotenv()

    if args.dry_run:
        tasks = SAMPLE_TASKS
        print("DRY RUN — sample tasks, no database, no API call.\n")
        print(build_prompt(tasks))
        print("\n--- rule-based priorities (what the fallback would write) ---")
        for t in tasks:
            priority, reason = rule_priority(t, t["open_count"])
            print("task %s %-28s -> %s (%s)" % (t["task_id"], t["title"], priority, reason))
        return 0

    import mysql.connector

    conn = mysql.connector.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=int(os.environ.get("DB_PORT", "3306")),
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        database=os.environ.get("DB_NAME", "multitask"),
    )
    tasks = load_tasks(conn)
    if args.limit:
        tasks = tasks[: args.limit]
    if not tasks:
        print("No open tasks. Nothing to do.")
        return 0

    api_key = os.environ.get("GEMINI_API_KEY")
    try:
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY not set")
        results = ask_gemini(api_key, tasks)
        print("Gemini suggested priorities for %d tasks." % len(results))
    except Exception as exc:  # noqa: BLE001 - fall back to rules
        print("AI call failed (%s). Using the rule-based scorer." % exc)
        results = {t["task_id"]: rule_priority(t, t["open_count"]) for t in tasks}

    # fill any gaps the model left with the rule-based scorer
    for t in tasks:
        if t["task_id"] not in results:
            results[t["task_id"]] = rule_priority(t, t["open_count"])

    save_priorities(conn, results)
    conn.close()
    for task_id, (priority, reason) in sorted(results.items()):
        print("task %s -> %s (%s)" % (task_id, priority, reason))
    print("Saved %d priorities." % len(results))
    return 0


if __name__ == "__main__":
    sys.exit(main())
