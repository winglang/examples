import { cloud, lift, main } from "@wingcloud/framework";
import { myServer } from "./my-ssr-framework";
import assert from "node:assert";

main((root, test) => {
  let bucket = new cloud.Bucket(root, "Bucket");

  bucket.addObject("hello", "Hello World from lifted Bucket!");

  new cloud.Function(root, "hello", lift({bucket}).inflight(async ({bucket}) => {
    const result = await myServer({bucket})
    return result;
  }));

  test("testing it works", lift({bucket}).inflight(async ({bucket}) => {
    const result = await myServer({bucket})
    assert.equal(result , "Hello World from lifted Bucket!");
  }))
})