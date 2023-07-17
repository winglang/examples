bring cloud;
bring ex;
bring util;

let queue = new cloud.Queue();
let redis = new ex.Redis();

queue.setConsumer(inflight (message: str) => {
  redis.set("hello", message);
}, timeout: 3s);

test "Hello, world!" {
  queue.push("world!");

  util.waitUntil((): bool => {
    log("Checking if redis key exists");
    redis.get("hello") != nil;
  });

  assert("world!" == "${redis.get("hello")}");
}