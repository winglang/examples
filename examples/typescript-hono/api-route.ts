import type { cloud } from "@wingcloud/framework";
import { lift } from "@wingcloud/framework";
import { handleRequest } from "./mapper";

export const apiRoute = (api: cloud.Api, path: string, ctx?: {bucket: cloud.Bucket}) => {
  const liftedHandler = () => {
    return lift({ apiUrl: api.url, bucket: ctx ? ctx.bucket : undefined}).inflight(async ({ apiUrl, bucket }, req) => {
      return handleRequest(apiUrl, req, bucket);
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