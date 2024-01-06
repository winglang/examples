bring cloud;
bring util;
bring expect;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.setConsumer(inflight (message) => {
  bucket.put("wing.txt", "Hello, {message}");
}, timeout: 1s);

// tests

test "Hello, world!" {
  queue.push("world!");

  let found = util.waitUntil(() => {
    return bucket.exists("wing.txt");
  });

  expect.equal(bucket.get("wing.txt"), "Hello, world");
}