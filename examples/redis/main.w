bring cloud;
bring ex;
bring util;
bring expect;

let queue = new cloud.Queue();
let redis = new ex.Redis();

queue.setConsumer(inflight (message) => {
  redis.set("hello", message);
}, timeout: 3s);

test "Hello, world!" {
  queue.push("world!");

  util.waitUntil(() => {
    log("Checking if redis key exists");
    redis.get("hello") != nil;
  });

  expect.equal(redis.get("hello"), "world!");
}