bring cloud;
bring util;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.setConsumer(inflight (message: str) => {
  bucket.put("wing.txt", "Hello, ${message}");
}, timeout: 1s);

let getTimeout = ():duration => {
  if util.env("WING_TARGET") == "sim" {
    return 1s;
  }
  return 10s;
};

let timeout = getTimeout();

test "Hello, world!" {
  queue.push("world!");
  util.sleep(timeout);
  assert("Hello, wo!" == bucket.get("wing.txt"));
}