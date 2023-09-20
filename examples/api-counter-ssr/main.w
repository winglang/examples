bring cloud;
bring util;
bring http;

class Utils {
  extern "./utils.js" pub static inflight render(template: str, value: num): str;
  // This is a workaround for the pending fs module
  // https://github.com/winglang/wing/issues/3096
  extern "./utils.js" pub static readFile(filePath: str): str;
  init() { }
}

let templates = new cloud.Bucket();
templates.addObject("index.html", Utils.readFile("./index.html"));

let counter = new cloud.Counter();
let api = new cloud.Api();

api.get("/", inflight (req) => {
  let count = counter.inc();
  let rendered = Utils.render(templates.get("index.html"), count);

  return {
    status: 200,
    headers: {
      "Content-Type" => "text/html"
    },
    body: rendered
  };
});

// workaround for https://github.com/winglang/wing/issues/3289
// this shouldn't be necessary, since api.url should
// be directly accessible in the test
let apiUrl = api.url;

let invokeAndAssert = inflight(url: str, expected: str) => {
  let response = http.get(url);
  assert(response.status == 200);
  assert(response.body?.contains(expected) == true);
};

test "renders the index page" {
  invokeAndAssert(apiUrl, "Hello, Wing 0");
  invokeAndAssert(apiUrl, "Hello, Wing 1");
  invokeAndAssert(apiUrl, "Hello, Wing 2");
}
