import { cloud, main, lift } from "@wingcloud/framework";
import { app } from "./hono";

main((root, test) => {
  let bucket = new cloud.Bucket(root, "Bucket");

  bucket.addObject("hello", "Hello World from lifted Bucket!");

  const api = new cloud.Api(root, "api");

  api.get(
    "/api",
    lift({ apiUrl: api.url }).inflight(async ({ apiUrl }, req) => {
      const request = new Request(`${apiUrl}${req.path}`, {
        headers: req.headers,
        method: req.method,
      });
      const response = await app.fetch(request);

      let headers: Record<string, string> = {};
      response.headers.forEach((value, name) => {
        headers[name] = value;
      });

      return {
        status: response.status,
        headers,
        body: await response.text(),
      };
    })
  );

  test(
    "GET /api",
    lift({ apiUrl: api.url }).inflight(async ({ apiUrl }) => {
      const response = await fetch(`${apiUrl}/api`);
      console.log(await response.text());
    })
  );
});
