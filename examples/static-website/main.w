bring cloud;
bring util;
bring http;

let website = new cloud.Website(
  path: "./static",
);

let api = new cloud.Api();
website.addJson("config.json", { api: api.url });

let counter = new cloud.Counter() as "website-counter";

let corsHandler = inflight(req: cloud.ApiRequest): cloud.ApiResponse => {
  return cloud.ApiResponse {
    headers: {
      "Access-Control-Allow-Headers" => "*",
      "Access-Control-Allow-Origin" => "*",
      "Access-Control-Allow-Methods" =>  "OPTIONS,POST",
    },
    status: 204
  };
};
api.options("/hello-static", corsHandler);
api.post("/hello-static", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
  return cloud.ApiResponse {
    status: 200,
    headers: {
      "Content-Type" => "text/html",
      "Access-Control-Allow-Origin" => "*",
    },
    body: "<div id=\"hello\" class=\"mt-4\">Hello ${counter.inc()}</div>",
  };
});

// workaround for https://github.com/winglang/wing/issues/3289
// this shouldn't be necessary, since api.url should
// be directly accessible  in the test
let apiUrl = api.url;

// However, while this worked for API, it doesn't work for
// the website.url property :/
let websiteUrl = website.url;

let invokeAndAssert = inflight(response: http.Response, expected: str) => {
  log("response: ${response.status} ");
  assert(response.status == 200);
  assert(response.body?.contains(expected) == true);
};

// Doesn't work right now
// test "renders the index page" {
//   invokeAndAssert(http.get(websiteUrl), "Hello, Wing");
// }

test "api returns the correct response" {
  invokeAndAssert(http.post("${apiUrl}/hello-static"), "Hello 0");
}
