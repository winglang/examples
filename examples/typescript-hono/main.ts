import { cloud, inflight, main } from "@wingcloud/framework";
import myServer from "./hono";

const streamToString = async (stream: ReadableStream) => {
  let reader = stream.getReader();
  let decoder = new TextDecoder('utf-8');
  let data = await reader.read();
  let body = '';

  while (!data.done) {
    body += decoder.decode(data.value, {stream: true});
    data = await reader.read();
  }

  body += decoder.decode(); // finish the stream
  return body;
}

main((root, test) => {
  let bucket = new cloud.Bucket(root, "Bucket");

  bucket.addObject("hello", "Hello World from lifted Bucket!");

  const api = new cloud.Api(root, "api");

  api.get("/api", inflight(async (ctx, req) => {
    const requestInit: RequestInit = {
      headers: req.headers,
      method: req.method,
    }

    const request = new Request(`${api.url}/${req.path}`, requestInit);
    const result = await myServer.fetch(request);
    let headersRecord: Record<string, string> = {};
    result.headers.forEach((value: any, name: any) => {
      headersRecord[name] = value;
    });
    return {
      status: result.status,
      headers: headersRecord,
      body: await streamToString(result.body)
    }
  })) ;
})