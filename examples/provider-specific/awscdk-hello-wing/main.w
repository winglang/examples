bring cloud;
bring util;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.setConsumer(inflight (message: str) => {
  bucket.put("wing.txt", "Hello, ${message}");
}, timeout: 1s);

// tests

let getTimeout = ():duration => {
  if util.env("WING_TARGET") == "sim" {
    return 1s;
  }
  return 5s;
};

let timeout = getTimeout();

test "Hello, world!" {
  queue.push("world!");
  util.sleep(timeout);
  assert("Hello, world!" == bucket.get("wing.txt"));
}
