bring cloud;
bring redis;
bring util;
bring expect;

let queue = new cloud.Queue();
let cache = new redis.Redis();

queue.setConsumer(inflight (message) => {
  cache.set("hello", message);
}, timeout: 3s);

test "Hello, world!" {
  queue.push("world!");
  util.waitUntil(() => {
    return cache.get("hello") != nil;
  });

  expect.equal(cache.get("hello"), "world!");
}