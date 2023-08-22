# To-Do List app

A backend only (at this point) app to manage a list of tasks to-do.
Exposes a REST based API to manage the list.

Currently supports the following operations:
1. Add a new task to the list (POST).
2. Update the status of an existing task to COMPLETED (PUT).
3. Retrieve a task by ID (GET).
4. Delete an existing task (DELETE).
5. Retrieve all tasks, filter by a search string (GET).

## Example REST calls:
1. POST, Request body: `{"description": "land on the moon"}`.
2. POST, Request body: `{"description": "random"}` (generates a random task description).
3. PUT, Request body: `{"id":0, "description": "land on the moon", "status": "COMPLETED"}`.

*For all calls, add the `Content-Type: application/json` header.*

## Implementation details:
1. Uses an `ex.Redis` resource to store the tasks.
2. Uses a `cloud.API` resource to expose the REST API.
3. Uses an external javascript file `tasklist_helper.js` to utilize regular expressions.