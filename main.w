bring cloud;
bring http;
bring "./basic-auth.w" as auth;

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

let apiUrl = api.url;

test "not authenticated" {
  let response = http.get("${apiUrl}/hello-middleware");
  assert(response.status == 401);
}

test "authenticated" {
  let response = http.get("${apiUrl}/hello-middleware", {
    headers: {
      Accept: "application/json",
      Authorization: "Basic " + auth.Utils.base64encode("admin:admin")
    }
  });

  assert(response.status == 200);
}
