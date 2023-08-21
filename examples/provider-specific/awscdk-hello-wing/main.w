bring cloud;
bring util;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.setConsumer(inflight (message) => {
  bucket.put("wing.txt", "Hello, ${message}");
}, timeout: 1s);

// tests

test "Hello, world!" {
  queue.push("world!");

  let found = util.waitUntil(() => {
    return bucket.exists("wing.txt");
  });

  assert("Hello, world!" == bucket.get("wing.txt"));
}