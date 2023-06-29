bring cloud;
bring util;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.setConsumer(inflight (message: str) => {
  bucket.put("wing.txt", "Hello, ${message}");
}, timeout: 1s);

test "Hello, world!" {
  let var timeout = 1s;
  if util.env("WING_TARGET") != "sim" {
    timeout = 10s;
  }

  queue.push("world!");
  util.sleep(timeout);
  assert("Hello, world!" == bucket.get("wing.txt"));
}