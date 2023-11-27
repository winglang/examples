bring cloud;
bring util;

pub struct Credentials {
  username: str;
  password: str;
}

pub class BasicAuth {
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
    } catch {
      log("exception caught - no auth header");
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
      return "${authHeader}";
    } else {
      log("headers: ${Json.stringify(headers)}");
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
