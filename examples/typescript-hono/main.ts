import { cloud, main, lift } from "@wingcloud/framework";
import { handleRequest } from "./mapper";
import { match } from "node:assert";

main((root, test) => {
  let bucket = new cloud.Bucket(root, "Bucket");

  bucket.addObject("hello", "Hello World from lifted Bucket!");

  const api = new cloud.Api(root, "api");

  api.get(
    "/",
    lift({ apiUrl: api.url }).inflight(async ({ apiUrl }, req) => {
      return handleRequest(apiUrl, req);
    })
  );

  api.get(
    "/api",
    lift({ apiUrl: api.url }).inflight(async ({ apiUrl }, req) => {
      return handleRequest(apiUrl, req);
    })
  );

  test(
    "GET /",
    lift({ apiUrl: api.url }).inflight(async ({ apiUrl }) => {
      const response = await fetch(apiUrl);
      const text = await response.text();
      match(text, /Good Morning/);
    })
  );

  test(
    "GET /api",
    lift({ apiUrl: api.url }).inflight(async ({ apiUrl }) => {
      const response = await fetch(`${apiUrl}/api`);
      const text = await response.text();
      match(text, /Hello World/);
    })
  );
});
