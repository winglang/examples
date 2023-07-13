bring cloud;
bring util;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.setConsumer(inflight (message: str) => {
  bucket.put("wing.txt", "Hello, ${message}");
}, timeout: 3s);

test "Hello, world!" {
  queue.push("world!");

  let found = util.waitUntil((): bool => {
    log("Checking if wing.txt exists");
    return bucket.exists("wing.txt");
  });

  assert("Hello, world!" == bucket.get("wing.txt"));
}