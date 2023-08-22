bring cloud;
bring "./node_modules/@skorfmann/wing-assertions/main.w" as t;

let bucket = new cloud.Bucket();

test "bucket exists" {
  t.Assert.equalStr(bucket.node.addr, "c8962f0cd81d488253a50c5fab66f85708ed7b9545");
}