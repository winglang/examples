bring cloud;
bring http;
bring "./basic-auth.w" as auth;
bring expect;

class Wrapper {
  pub apiUrl: str;

  new() {
    let basicAuth = new auth.BasicAuth();

    // conflicting with ../api-basic-auth/ application
    // https://github.com/winglang/wing/issues/3224
    let api = new cloud.Api() as "basic-auth-middleware-api";

    // class based inflight functions are not yet supported
    // see https://github.com/winglang/wing/issues/3250
    let authenticatedMiddleware = (handler: inflight (cloud.ApiRequest): cloud.ApiResponse): inflight (cloud.ApiRequest): cloud.ApiResponse => {
      let middleware = inflight (req: cloud.ApiRequest): cloud.ApiResponse => {
        let authenticated = basicAuth.call(req);
        if (!authenticated) {
          return cloud.ApiResponse {
            status: 401,
            headers: {
              "Content-Type" => "text/plain"
            },
            body: "Unauthorized"
          };
        } else {
          return handler(req);
        }
      };

      return middleware;
    };

    api.get("/hello-middleware", authenticatedMiddleware(inflight (request) => {
      return {
        status: 200,
        headers: {
          "Content-Type" => "text/plain"
        },
        body: "hello world"
      };
    }));

    this.apiUrl = api.url;
  }
}

// workaround for https://github.com/winglang/wing/issues/3289
// this shouldn't be necessary, since api.url should
// be directly accessible in the test
let api = new Wrapper();

test "not authenticated" {
  let response = http.get("{api.apiUrl}/hello-middleware");
  expect.equal(response.status, 401);
}

test "authenticated" {
  let response = http.get("{api.apiUrl}/hello-middleware", {
    headers: {
      Accept: "application/json",
      Authorization: "Basic " + auth.Utils.base64encode("admin:admin")
    }
  });
  expect.equal(response.status, 200);
}