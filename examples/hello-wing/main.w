bring cloud;
bring util;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.setConsumer(inflight (message) => {
  bucket.put("wing.txt", "Hello, ${message}");
}, timeout: 30s);

test "Hello, world!" {
  queue.push("world!");

  let found = util.waitUntil(() => {
    log("Checking if wing.txt exists");
    return bucket.exists("wing.txt");
  });

  assert("Hello, world!" == bucket.get("wing.txt"));
}