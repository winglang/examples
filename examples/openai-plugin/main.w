bring cloud;

class Utils {
  init() {}
  extern "./util.js" readFile(path: str): str;
  extern "./util.js" inflight getIssues(): str;
}

inflight class TestUtils {
  init() {}
  extern "./test-util.js" inflight fetch(url: str, method: str, body: str?): Array<Json>;
  extern "./test-util.js" inflight mockFetch(): void;
  extern "./test-util.js" inflight resetMocks(): void;
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
    headers: {
      "Content-Type": "application/json"
    },
    body: Json.stringify(fileContent),
  };
});

api.options("/${aiPluginPath}", options_handler);
api.get("/${aiPluginPath}", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
  let fileContent = bucket.getJson(aiPluginPath);

  return cloud.ApiResponse {
    status: 200,
    headers: {
      "Content-Type": "application/json"
    },
    body: Json.stringify(fileContent),
  };
});

api.options("/issues", options_handler);
api.get("/issues", inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
  let issues = utils.getIssues();

  return cloud.ApiResponse {
    status: 200,
    headers: {
      "Content-Type": "application/json"
    },
    body: Json.stringify(issues),
  };
});

// test "fetch issues" {
//   log("loading test utils");
//   let testUtils = new TestUtils();
//   testUtils.mockFetch();
//   log("url: ${api.url}");
//   let result = testUtils.fetch("${api.url}/issues", "GET");
//   let titles = MutArray<str>[];
//   for issue in result {
//     log("${issue.get("title")}");
//     titles.push(str.fromJson(issue.get("title")));
//   }

//   let expected = Array<str>[
//     "Contributor experience: quick build+tests on a Windows machine to test and fix Windows related issues faster",
//     "Build sporadically fails in CI when installing npm using volta",
//     "Skip publishing new version of VS code extension when ",
//     "QueueProps.timeout doesn't work on both sim and tf-aws",
//     "Add hint about how to convert MutArray to Array",
//     "fetch in wing standard library",
//     "`size` primitive type",
//     "Naming a resource method with the same name as a field causes a compiler panic",
//     "Update Counter.inc, peek, and dec with `key` argument",
//     "string interpolation fails on dollar sign"
//   ];

//   assert(Json.stringify(titles) == Json.stringify(expected));
//   testUtils.resetMocks();
// }

test "fetch issues" {
  log("loading test utils");
  log("url: ${api.url}");
  let testUtils = new TestUtils();
  testUtils.mockFetch();
  let result = testUtils.fetch("${api.url}/issues", "GET");
  let titles = MutArray<str>[];
  for issue in result {
    log("issue: ${issue}");
    log("${issue.get("title")}");
    titles.push(str.fromJson(issue.get("title")));
  }

  // let expected = Array<str>[
  //   "Contributor experience: quick build+tests on a Windows machine to test and fix Windows related issues faster",
  //   "Build sporadically fails in CI when installing npm using volta",
  //   "Skip publishing new version of VS code extension when ",
  //   "QueueProps.timeout doesn't work on both sim and tf-aws",
  //   "Add hint about how to convert MutArray to Array",
  //   "fetch in wing standard library",
  //   "`size` primitive type",
  //   "Naming a resource method with the same name as a field causes a compiler panic",
  //   "Update Counter.inc, peek, and dec with `key` argument",
  //   "string interpolation fails on dollar sign"
  // ];

  // assert(Json.stringify(titles) == Json.stringify(expected));
  // testUtils.resetMocks();
}