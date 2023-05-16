bring cloud;

let bucket = new cloud.Bucket();
let queue = new cloud.Queue();

queue.addConsumer(inflight (message: str) => {
  bucket.put("wing.txt", "Hello, ${message}");
});

// tests

class TestHelper {
  init(){}
  extern "./sleep.js" inflight sleep(milli: num);
}

let js = new TestHelper();

test "Hello, world!" {
  queue.push("world!");
  // how do we wait for the queue to be empty / the consumer to finish?
  js.sleep(1000);
  assert("Hello, world!" == bucket.get("wing.txt"));
}