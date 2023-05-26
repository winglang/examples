bring cloud;
bring util;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.addConsumer(inflight (message: str) => {
  bucket.put("wing.txt", "Hello, ${message}");
}, timeout: 1s);

// tests

class TestHelper {
  init(){}
  extern "./sleep.js" inflight sleep(milli: num);
}

let js = new TestHelper();

let getTimeout = ():duration => {
  if util.env("WING_TARGET") == "sim" {
    return 1s;
  }
  return 10s;
};

let timeout = getTimeout();

test "Hello, world!" {
  queue.push("world!");
  js.sleep(timeout.seconds * 1000);
  assert("Hello, world!" == bucket.get("wing.txt"));
}