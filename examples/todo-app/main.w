bring cloud;
bring ex;
bring util;
bring http;
bring expect;

enum Status {
  PENDING, COMPLETED
}

struct Task {
  id: str;
  description: str;
  status: str;
}

// Currently interfaces must explicitly extend std.IResource - see https://github.com/winglang/wing/issues/1961
interface IRegExp extends std.IResource {
  inflight test(s: str): bool;
}

interface ITaskStorage extends std.IResource {
  inflight add(description: str): str;
  inflight remove(id: str);
  inflight get(id: str): Task?;
  inflight setStatus(id: str, status: Status);
  inflight find(r: IRegExp): Array<Task>;
}

/********************************************************************
 * Boilerplate code we'd love to get rid of as Winglang develops {
 ********************************************************************/

// Util method to get Status enum from str
let convertStrToStatusEnum = inflight (s: str): Status => {
  if s == "COMPLETED" {
    return Status.COMPLETED;
  }
  elif s == "PENDING" {
    return Status.PENDING;
  }
  else {
    throw("Unknown task status: ${s}");
  }
};

// Util method to get str from Status enum
let convertStatusEnumToStr = inflight (s: Status): str => {
  if s == Status.COMPLETED {
    return "COMPLETED";
  }
  elif s == Status.PENDING {
    return "PENDING";
  }
  else {
    throw("Unknown task status: ${s}");
  }
};

// Util method to convert Task array to JSON
let convertTaskArrayToJson = inflight (taskArray: Array<Task>): Json => {
  let jsonArray = MutJson [];
  let var i = 0;
  for task in taskArray {
    let j = Json task;
    jsonArray.setAt(i, j);
    i += 1;
  }
  return jsonArray;
};
/********************************************************************
 * } end of boilerplate code
 ********************************************************************/

class TaskStorage impl ITaskStorage {
  db: ex.Redis;
  counter: cloud.Counter;

  new() {
    this.db = new ex.Redis();
    this.counter = new cloud.Counter();
  }

  inflight _add(id: str, j: Json) {
    this.db.set(id , Json.stringify(j));
    this.db.sadd("tasks", id);
  }

  pub inflight add(description: str): str {
    let id = "${this.counter.inc()}";
    let taskJson = {
      id: id,
      description: description,
      status: "PENDING"
    };
    this._add(id, taskJson);
    log("adding task ${id} with data: ${taskJson}");
    return id;
  }

  pub inflight remove(id: str) {
    this.db.del(id);
    log("removing task ${id}");
  }

  pub inflight get(id: str): Task? {
    if let taskJson = this.db.get(id) {
      return Task.fromJson(Json.parse(taskJson));
    }
  }

  pub inflight setStatus(id: str, status: Status) {
    if let taskJsonStr = this.db.get(id) {
      let taskJson = Json.deepCopyMut(Json.parse(taskJsonStr));
      taskJson.set("status", convertStatusEnumToStr(status));
      this._add(id, taskJson);
      log("setting status of task ${id} to ${status}");
    }
  }

  pub inflight find(r: IRegExp): Array<Task> {
    let result = MutArray<Task>[];
    let ids = this.db.smembers("tasks");
    for id in ids {
      if let taskJsonStr = this.db.get(id) {
        let taskJson = Json.parse(taskJsonStr);
        if r.test(taskJson.get("description").asStr()) {
          result.push(Task.fromJson(taskJson));
        }
      }
    }
    return result.copy();
  }
}

class TaskService {
  pub api: cloud.Api;
  taskStorage: ITaskStorage;

  extern "./tasklist_helper.js" static inflight createRegex(s: str): IRegExp;

  new(storage: ITaskStorage) {
    this.api = new cloud.Api(cors: true);
    this.taskStorage = storage;

    // API endpoints
    this.api.post("/tasks", inflight (req): cloud.ApiResponse => {
      if let body = req.body {
        let var description = Json.parse(body).get("description").asStr();
        // Easter Egg - if you add a task with the single word "random" as the description,
        //              the system will fetch a random task from the internet
        if description == "random" {
          let response = http.get("https://www.boredapi.com/api/activity");
          let body = Json.parse(response.body);
          description = str.fromJson(body.get("activity"));
        }
        let id = this.taskStorage.add(description);
        return {
          status:201,
          body: id
        };
      } else {
        return {
          status: 400,
        };
      }
    });

    this.api.put("/tasks/{id}", inflight (req): cloud.ApiResponse => {
      if let body = req.body {
        let id = req.vars.get("id");
        if Json.parse(body).get("status").asStr() == "COMPLETED" {
          this.taskStorage.setStatus(id, Status.COMPLETED);
        } else {
          this.taskStorage.setStatus(id, Status.PENDING);
        }
        try {
          if let taskJson = this.taskStorage.get(id) {
            return {
              status:200,
              body: "${Json taskJson}"
            };
          }
        } catch {
          return {
            status: 400
          };
        }
      } else {
        return {
          status: 400
        };
      }
    });

    this.api.get("/tasks/{id}", inflight (req): cloud.ApiResponse => {
      let id = req.vars.get("id");
      try {
        if let taskJson = this.taskStorage.get(id) {
          return {
            status:200,
            body: "${Json taskJson}"
          };
        }
        else {
          return {
            status:404,
          };
        }
      } catch {
        return {
          status: 400
        };
      }
    });

    this.api.delete("/tasks/{id}", inflight (req): cloud.ApiResponse => {
      let id = req.vars.get("id");
      try {
        this.taskStorage.remove(id);
        return {
          status: 204 };
      } catch {
        return {
          status: 400
        };
      }
    });

    this.api.get("/tasks", inflight (req): cloud.ApiResponse => {
      let search = req.query.get("search");
      let results = this.taskStorage.find(TaskService.createRegex(search));
      return {
        status: 200,
        body: "${convertTaskArrayToJson(results)}"
      };
    });
  }
}

let storage = new TaskStorage();
let taskApi = new TaskService(storage);

test "list tasks" {
  storage.add("task 1");
  let url = taskApi.api.url;
  let response = http.get("${url}/tasks?search=task");
  log("response: ${Json.stringify(response.body)}");
  expect.equal(response.status, 200);
  expect.equal(response.body, Json.stringify(Json[{"id":"0","description":"task 1","status":"PENDING"}]));
  expect.equal(response.headers.get("access-control-allow-origin"), "*");
}
