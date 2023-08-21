bring cloud;
bring ex;
bring util;
bring http;

//TODO: need to fix:
// 1. when the list is empty, get fails

enum Status {
  PENDING, COMPLETED
}

struct Task {
  id: str;
  description: str;
  status: str;
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
  let jsonArray = MutJson {};
  let var i = 0;
  for task in taskArray {
    let j = Json task;
    jsonArray.setAt(i, j);
    i = i + 1;
  }
  return jsonArray;
};

// Constants - bolierplate code to enable CORS - see https://github.com/winglang/wing/issues/2289
let optionsTasksRouteAPICORSHeadersMap = {
  "Access-Control-Allow-Headers" => "Content-Type",
  "Access-Control-Allow-Origin" => "*",
  "Access-Control-Allow-Methods" => "OPTIONS,POST,GET"
};
let optionsTasksIdRouteAPICORSHeadersMap = {
  "Access-Control-Allow-Headers" => "Content-Type",
  "Access-Control-Allow-Origin" => "*",
  "Access-Control-Allow-Methods" => "OPTIONS,GET,PUT,DELETE"
};
let postAPICORSHeadersMap = {
  "Access-Control-Allow-Headers" => "Content-Type",
  "Access-Control-Allow-Origin" => "*",
  "Access-Control-Allow-Methods" => "OPTIONS,POST"
};
let putAPICORSHeadersMap = {
  "Access-Control-Allow-Headers" => "Content-Type",
  "Access-Control-Allow-Origin" => "*",
  "Access-Control-Allow-Methods" => "PUT"
};
let getAPICORSHeadersMap = {
  "Access-Control-Allow-Headers" => "Content-Type",
  "Access-Control-Allow-Origin" => "*",
  "Access-Control-Allow-Methods" => "OPTIONS,GET"
};
let deleteAPICORSHeadersMap = {
  "Access-Control-Allow-Headers" => "Content-Type",
  "Access-Control-Allow-Origin" => "*",
  "Access-Control-Allow-Methods" => "OPTIONS,DELETE"
};
/********************************************************************
 * } end of boilerplate code
 ********************************************************************/

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
      status: "PENDING"
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
      return Task.fromJson(Json.parse(taskJson));
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
          result.push(Task.fromJson(taskJson));
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
    
    this.api.options("/tasks", inflight(req: cloud.ApiRequest): cloud.ApiResponse => {
      return cloud.ApiResponse {
        headers: optionsTasksRouteAPICORSHeadersMap,
        status: 204
      };
    });
    this.api.options("/tasks/{id}", inflight(req: cloud.ApiRequest): cloud.ApiResponse => {
      return cloud.ApiResponse {
        headers: optionsTasksIdRouteAPICORSHeadersMap,
        status: 204
      };
    });
    
    // API endpoints
    this.api.post("/tasks", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      if let body = req.body {
        let var description = Json.parse(body).get("description").asStr();
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
          headers: postAPICORSHeadersMap,
          status:201, 
          body: id
        };
      } else {
        return cloud.ApiResponse { 
          headers: postAPICORSHeadersMap,
          status: 400,
          body: "Missing body"
        };
      }
    });
        
    this.api.put("/tasks/{id}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      if let body = req.body {
        let id = req.vars.get("id");
        if Json.parse(body).get("status").asStr() == "COMPLETED" {
          this.taskStorage.setStatus(id, Status.COMPLETED);
        } else {
          this.taskStorage.setStatus(id, Status.PENDING);
        }
        try {
          if let taskJson = this.taskStorage.get(id) {
            return cloud.ApiResponse { 
              headers: putAPICORSHeadersMap,
              status:200, 
              body: "${Json taskJson}"
            };
          }
        } catch {
          return cloud.ApiResponse { 
            headers: putAPICORSHeadersMap,
            status: 400 
          };
        }
      } else {
        return cloud.ApiResponse { 
          headers: putAPICORSHeadersMap,
          status: 400 
        };
      }
    });

    this.api.get("/tasks/{id}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      let id = req.vars.get("id");
      try {
        if let taskJson = this.taskStorage.get(id) {
          return cloud.ApiResponse { 
            headers: getAPICORSHeadersMap, 
            status:200, 
            body: "${Json taskJson}"
          };
        }
      } catch {
        return cloud.ApiResponse { 
          headers: getAPICORSHeadersMap, 
          status: 400 
        };
      }
    });
    
    this.api.delete("/tasks/{id}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      let id = req.vars.get("id");
      try {
        this.taskStorage.remove(id);
        return cloud.ApiResponse { 
          headers: deleteAPICORSHeadersMap,
          status: 204 };
      } catch {
        return cloud.ApiResponse { 
          headers: deleteAPICORSHeadersMap,
          status: 400 
        };
      }
    });

    this.api.get("/tasks", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
      let search = req.query.get("search");
      let results = this.taskStorage.find(this.createRegex(search));
      return cloud.ApiResponse { 
        headers: getAPICORSHeadersMap,  
        status: 200, 
        body: "${convertTaskArrayToJson(results)}" 
      };
    });
  }
}

let taskApi = new TaskApi();
