# To-Do List App API

A backend only (at this point) app to manage a list of to-do tasks.
Exposes a REST based API to manage the list.

## Features
1. Create new task (POST).
2. Update task status to COMPLETED (PUT).
3. Retrieve task by ID (GET).
4. Delete task (DELETE).
5. Find all tasks matching a search string (GET).

## Example REST calls:
1. Add Task:
   * Method: POST
   * Body: `{"description": "land on the moon"}`
2. Add a random task:
   * Method: POST
   * Body: `{"description": "random"}`
3. Mark task as completed:
   * Method: PUT
   * Body: `{"id":0, "description": "land on the moon", "status": "COMPLETED"}`

*🔔 Note: Ensure that `Content-Type: application/json` header is included in all requests.*

## Implementation notes:
1. Uses an `ex.Redis` resource to store the tasks.
2. Uses a `cloud.API` resource to expose the REST API.
3. Uses an external javascript file `tasklist_helper.js` to utilize regular expressions.