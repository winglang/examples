bring cloud;
bring ex;

let redis = new ex.Redis();

class Utils {
  extern "./utils.js" pub static inflight uuid(): str;  
}

new cloud.OnDeploy(inflight () => {
  redis.set("hello", Utils.uuid());
});

test "Hello, world!" {
  assert(redis.get("hello")?.length == 36);
}
