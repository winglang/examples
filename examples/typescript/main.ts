import { cloud, lift, main, std } from "ts4w";

main((app) => {
  let bucket = new cloud.Bucket(app, "Bucket");

  bucket.addObject("hello", "Hello World from lifted Bucket!");

  new cloud.Function(app, "hello", lift({bucket}).inflight(async ({bucket}) => {
    const { myServer } = require("/Users/sebastian/projects/wing-cloud/examples/examples/typescript/my-ssr-framework.ts");
    const result = await myServer({bucket})
    return result;
  }));

  new std.Test(app, "test", lift({bucket}).inflight(async ({bucket}) => {
    const { equal } = require("node:assert");
    const { myServer } = require("/Users/sebastian/projects/wing-cloud/examples/examples/typescript/my-ssr-framework.ts");
    const result = await myServer({bucket})
    equal(result , "Hello World from lifted Bucket!");
  }))
})