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
    return redis.get("hello") != nil;
  });

  expect.equal(redis.get("hello"), "world!");
}