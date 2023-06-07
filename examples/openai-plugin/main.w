bring cloud;

class Utils {
  init() {}
  extern "./util.js" readFile(path: str): str;
  extern "./util.js" inflight getIssues(): str;
}

let utils = new Utils();

let bucket = new cloud.Bucket();
let openapiPath = "openapi.json";
let aiPluginPath = ".well-known/ai-plugin.json";

bucket.addObject(openapiPath, utils.readFile(openapiPath));
bucket.addObject(aiPluginPath, utils.readFile(aiPluginPath));

let api = new cloud.Api();

let options_handler = inflight(req: cloud.ApiRequest): cloud.ApiResponse => {
  return cloud.ApiResponse {
    headers: {
      "Access-Control-Allow-Headers" : "Content-Type",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
    },
    status: 204
  };
};

api.options("/${openapiPath}", options_handler);
api.get("/${openapiPath}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
  let fileContent = bucket.getJson(openapiPath);

  return cloud.ApiResponse {
    status: 200,
    body: fileContent
  };
});

api.options("/${aiPluginPath}", options_handler);
api.get("/${aiPluginPath}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
  let fileContent = bucket.getJson(aiPluginPath);

  return cloud.ApiResponse {
    status: 200,
    body: fileContent,
  };
});

api.options("/issues", options_handler);
api.get("/issues", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
  let issues = utils.getIssues();

  return cloud.ApiResponse {
    status: 200,
    body: issues,
  };
});