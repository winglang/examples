bring cloud;
bring util;
bring http;
bring expect;

struct Credentials {
  username: str;
  password: str;
}

class BasicAuth {
  user: str;
  password: str;

  new(user: str?, password: str?) {
    this.user = user ?? "admin";
    this.password = password ?? "admin";
  }

  pub inflight call(req: cloud.ApiRequest): bool {
    try {
      let authHeader = this.authHeader(req.headers);
      let credentials = this.authCredentials(authHeader);
      let username = credentials.username;
      let password = credentials.password;
      return username == this.user && password == this.password;
    } catch e {
      log("exception caught {e}");
      return false;
    }
  }

  inflight authCredentials(header: str): Credentials {
    let auth = util.base64Decode(header.split(" ").at(1));
    let splittedAuth = auth.split(":");
    let username = splittedAuth.at(0);
    let password = splittedAuth.at(1);

    return Credentials {
      username: username,
      password: password
    };
  }
  // workaround for https://github.com/winglang/wing/issues/3205
  inflight authHeader(headers: Map<str>?): str {
    if (this.authHeaderPresent(headers)) {
      let authHeaderOptional = headers?.tryGet("authorization");
      let var authHeader = headers?.tryGet("Authorization");

      if (authHeader == nil) {
        authHeader = authHeaderOptional;
      }

      // force cast to str from str?
      return "{authHeader}";
    } else {
      log("headers: {Json.stringify(headers)}");
      log("no auth header");
      throw("no auth header");
    }
  }

  // workaround for https://github.com/winglang/wing/issues/3205
  inflight authHeaderPresent(headers: Map<str>?): bool {
    if (headers?.has("authorization") == false) && (headers?.has("Authorization") == false) {
      return false;
    }
    return true;
  }
}

let auth = new BasicAuth();
let api = new cloud.Api();

api.get("/hello", inflight (req) => {
  let authenticated = auth.call(req);

  if (!authenticated) {
    return {
      status: 401,
      headers: {
        "Content-Type" => "text/plain"
      },
      body: "Unauthorized"
    };
  }

  return {
    status: 200,
    headers: {
      "Content-Type" => "text/plain"
    },
    body: "hello world"
  };
});

// workaround for https://github.com/winglang/wing/issues/3289
// this shouldn't be necessary, since api.url should
// be directly accessible in the test
let apiUrl = api.url;

test "not authenticated" {
  let response = http.get("{apiUrl}/hello");
  expect.equal(response.status, 401);
}

test "authenticated" {
  let response = http.get("{apiUrl}/hello", {
    headers: {
      Accept: "application/json",
      Authorization: "Basic " + util.base64Encode("admin:admin")
    }
  });

  expect.equal(response.status, 200);
}