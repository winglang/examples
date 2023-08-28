bring cloud;
bring util;
bring http;

let website = new cloud.Website(
  path: "./static",
);

let api = new cloud.Api();
website.addJson("config.json", { api: api.url });

let counter = new cloud.Counter() as "website-counter";

let corsHandler = inflight(req) => {
  return {
    headers: {
      "Access-Control-Allow-Headers" => "*",
      "Access-Control-Allow-Origin" => "*",
      "Access-Control-Allow-Methods" =>  "OPTIONS,POST",
    },
    status: 204
  };
};
api.options("/hello-static", corsHandler);
api.post("/hello-static", inflight (request) => {
  return {
    status: 200,
    headers: {
      "Content-Type" => "text/html",
      "Access-Control-Allow-Origin" => "*",
    },
    body: "<div id=\"hello\" class=\"mt-4\">Hello ${counter.inc()}</div>",
  };
});

let invokeAndAssert = inflight(response: http.Response, expected: str) => {
  log("response: ${response.status} ");
  assert(response.status == 200);
  assert(response.body?.contains(expected) == true);
};

test "renders the index page" {
  invokeAndAssert(http.get(website.url), "Hello, Wing");
}

test "api returns the correct response" {
  invokeAndAssert(http.post("${api.url}/hello-static"), "Hello 0");
}
