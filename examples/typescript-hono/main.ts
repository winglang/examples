import { cloud, main, lift } from "@wingcloud/framework";
import { handleRequest } from "./mapper";
import { match } from "node:assert";

main((root, test) => {
  let bucket = new cloud.Bucket(root, "Bucket");

  bucket.addObject("hello", "Hello World from lifted Bucket!");

  const api = new cloud.Api(root, "api");

  const apiRoute = (path: string) => {
    const liftedHandler = () => {
      return lift({ apiUrl: api.url }).inflight(async ({ apiUrl }, req) => {
        return handleRequest(apiUrl, req);
      })
    }

    api.get(path, liftedHandler());
    api.post(path, liftedHandler());
    api.put(path, liftedHandler());
    api.patch(path, liftedHandler());
    api.delete(path, liftedHandler());
    api.connect(path, liftedHandler());
    api.options(path, liftedHandler());
  }

  apiRoute("/");
  apiRoute("/api");

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

  test(
    "POST /api",
    lift({ apiUrl: api.url }).inflight(async ({ apiUrl }) => {
      const response = await fetch(`${apiUrl}/api`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
      });
      const text = await response.text();
      match(text, /Posted/);
    })
  );
});
