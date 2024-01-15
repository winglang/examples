bring cloud;
bring util;
bring http;
bring ex;

let api = new cloud.Api();

api.get("/test", inflight (req) => {
  return cloud.ApiResponse {
    body: "working",
    status: 200
  };
});

let website = new ex.ReactApp(
  projectPath: "../website",
  localPort: 3002,
);

website.addEnvironment("REACT_APP_SERVER_URL",  api.url );
website.addEnvironment("G",  "123" );

test "reach host files" {
  log(website.url);
  util.waitUntil(inflight () => {
    try {
      log(website.url);
      http.get(website.url);
      return true;
    } catch err {
      return false;
    }
  }, util.WaitUntilProps {interval: 1s, timeout: 30s});
  assert(http.get(website.url).ok);
}
