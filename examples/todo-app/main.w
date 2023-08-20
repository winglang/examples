bring cloud;
bring ex;
bring util;
bring http;

enum Status {
  PENDING, COMPLETED
}

struct Task {
  id: str;
  description: str;
  status: Status;
}

// Currently interfaces must explicitly extend std.IResource - see https://github.com/winglang/wing/issues/1961
interface IMyRegExp extends std.IResource {
  inflight test(s: str): bool;
}

interface ITaskStorage extends std.IResource {
  inflight add(description: str): str;
  inflight remove(id: str);
  inflight get(id: str): Task?;
  inflight setStatus(id: str, status: Status);
  inflight find(r: IMyRegExp): Array<Task>;
}

// Util method to get Status enum from str
let convertStrToStatusEnum = inflight (s: str): Status => {
  if s == "${Status.COMPLETED}" {
    return Status.COMPLETED;
  }
  elif s == "${Status.PENDING}" {
    return Status.PENDING;
  }
  else {
    throw("Unknown task status: ${s}");
  }
};

// Util method to get str from Status enum
let convertStatusEnumToStr = inflight (s: Status): str => {
  if s == Status.COMPLETED {
    return "${Status.COMPLETED}";
  }
  elif s == Status.PENDING {
    return "${Status.PENDING}";
  }
  else {
    throw("Unknown task status: ${s}");
  }
};

// Util method to convert JSON to Task
let convertJsonToTask = inflight (j: Json): Task => {
  return Task {
    id: j.get("id").asStr(),
    description: j.get("description").asStr(),
    status: convertStrToStatusEnum(j.get("status").asStr()) 
  };
};

// Util method to convert Task to JSON
let convertTaskToJson = inflight (task: Task): Json => {
  return {
    id: task.id,
    description: task.description,
    status: convertStatusEnumToStr(task.status) 
  };
};

// Util method to convert Task array to JSON
let convertTaskArrayToJson = inflight (taskArray: Array<Task>): Json => {
  let jsonArray = MutJson {};
  let i = 0;
  for task in taskArray {
    let j = convertTaskToJson(task);
    jsonArray.setAt(i, j);
  }
  return jsonArray;
};

class TaskStorage impl ITaskStorage {
  db: ex.Redis;
  counter: cloud.Counter;

  init() {
    this.db = new ex.Redis();
    this.counter = new cloud.Counter();
  }

  inflight _add(id: str, j: Json) {
    this.db.set(id , Json.stringify(j));
    this.db.sadd("tasks", id);
  }

  inflight add(description: str): str {
    let id = "${this.counter.inc()}";
    let taskJson = {
      id: id,
      description: description,
      status: "${Status.PENDING}"
    };
    this._add(id, taskJson);
    log("adding task ${id} with data: ${taskJson}"); 
    return id;
  }

  inflight remove(id: str) {
    this.db.del(id);
    log("removing task ${id}");
  }

  inflight get(id: str): Task? {
    if let taskJson = this.db.get(id) {
      return convertJsonToTask(Json.parse(taskJson));
    }
  }

  inflight setStatus(id: str, status: Status) {
    if let taskJsonStr = this.db.get(id) {
      let taskJson = Json.deepCopyMut(Json.parse(taskJsonStr));
      taskJson.set("status", convertStatusEnumToStr(status));
      this._add(id, taskJson);
      log("setting status of task ${id} to ${status}");
    }
  }

  inflight find(r: IMyRegExp): Array<Task> { 
    let result = MutArray<Task>[]; 
    let ids = this.db.smembers("tasks");
    for id in ids {
      if let taskJsonStr = this.db.get(id) {
        let taskJson = Json.parse(taskJsonStr);
        if r.test(taskJson.get("description").asStr()) {
          result.push(convertJsonToTask(taskJson));
        }
      }
    }
    return result.copy();
  }
}

class TaskApi {
  api: cloud.Api;
  taskStorage: ITaskStorage;

  extern "./tasklist_helper.js" inflight createRegex(s: str): IMyRegExp;

  init() {
    this.api = new cloud.Api();
    this.taskStorage = new TaskStorage();
    
    // Bolierplate code to enable CORS - see https://github.com/winglang/wing/issues/2289
    this.api.options("/tasks", inflight(req: cloud.ApiRequest): cloud.ApiResponse => {
      return cloud.ApiResponse {
        headers: {
          "Access-Control-Allow-Headers" => "Content-Type",
          "Access-Control-Allow-Origin" => "*",
          "Access-Control-Allow-Methods" => "OPTIONS,POST,GET"
        },
        status: 204
      };
    });
    this.api.options("/tasks/{id}", inflight(req: cloud.ApiRequest): cloud.ApiResponse => {
      return cloud.ApiResponse {
        headers: {
            "Access-Control-Allow-Headers" => "Content-Type",
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "OPTIONS,GET,PUT,DELETE"
        },
        status: 204
      };
    });
    
    // API endpoints
    this.api.post("/tasks", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      if let body = req.body {
        let var description = body;
        // Easter Egg - if you add a task with the single word "random" as the description, 
        //              the system will fetch a random task from the internet
        if description == "random" {
          let response = http.get("https://www.boredapi.com/api/activity");
          if let responseBody = response.body {
            let body = Json.parse(responseBody);
            description = str.fromJson(body.get("activity"));
          }
        } 
        let id = this.taskStorage.add(description);
        return cloud.ApiResponse { 
          headers: {
              "Access-Control-Allow-Headers" => "Content-Type",
              "Access-Control-Allow-Origin" => "*",
              "Access-Control-Allow-Methods" => "OPTIONS,POST"
          },
          status:201, 
          body: id
        };
      } else {
        return cloud.ApiResponse { 
          headers: {
            "Access-Control-Allow-Headers" => "Content-Type",
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "OPTIONS,POST"
          },
          status: 400,
          body: "Missing body"
        };
      }
    });
        
    this.api.put("/tasks/{id}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      if let body = req.body {
        let id = req.vars.get("id");
        if Json.parse(body).get("status").asStr() == "${Status.COMPLETED}" {
          this.taskStorage.setStatus(id, Status.COMPLETED);
        } else {
          this.taskStorage.setStatus(id, Status.PENDING);
        }
        try {
          if let taskJson = this.taskStorage.get(id) {
            return cloud.ApiResponse { 
              headers: {
                "Access-Control-Allow-Headers" => "Content-Type",
                "Access-Control-Allow-Origin" => "*",
                "Access-Control-Allow-Methods" => "PUT"
              },
              status:200, 
              body: "${convertTaskToJson(taskJson)}"
            };
          }
        } catch {
          return cloud.ApiResponse { 
            headers: {
              "Access-Control-Allow-Headers" => "Content-Type",
              "Access-Control-Allow-Origin" => "*",
              "Access-Control-Allow-Methods" => "PUT"
            },
            status: 400 
          };
        }
      } else {
        return cloud.ApiResponse { 
          headers: {
            "Access-Control-Allow-Headers" => "Content-Type",
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "PUT"
          },
          status: 400 
        };
      }
    });

    this.api.get("/tasks/{id}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      let id = req.vars.get("id");
      try {
        if let taskJson = this.taskStorage.get(id) {
          return cloud.ApiResponse { 
            headers: {
              "Access-Control-Allow-Headers" => "Content-Type",
              "Access-Control-Allow-Origin" => "*",
              "Access-Control-Allow-Methods" => "OPTIONS,GET"
            }, 
            status:200, 
            body: "${convertTaskToJson(taskJson)}"
          };
        }
      } catch {
        return cloud.ApiResponse { 
          headers: {
            "Access-Control-Allow-Headers" => "Content-Type",
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "OPTIONS,GET"
          }, 
          status: 400 
        };
      }
    });
    
    this.api.delete("/tasks/{id}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      let id = req.vars.get("id");
      try {
        this.taskStorage.remove(id);
        return cloud.ApiResponse { 
          headers: {
            "Access-Control-Allow-Headers" => "Content-Type",
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "OPTIONS,DELETE"
          },
          status: 204 };
      } catch {
        return cloud.ApiResponse { 
          headers: {
            "Access-Control-Allow-Headers" => "Content-Type",
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Methods" => "OPTIONS,DELETE"
          },
          status: 400 
        };
      }
    });

    this.api.get("/tasks", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      let search = req.query.get("search");
      let results = this.taskStorage.find(this.createRegex(search));
      return cloud.ApiResponse { 
        headers: {
          "Access-Control-Allow-Headers" => "Content-Type",
          "Access-Control-Allow-Origin" => "*",
          "Access-Control-Allow-Methods" => "OPTIONS,GET"
        },  
        status: 200, 
        body: "${results}" 
      };
    });
  }
}

let taskApi = new TaskApi();
