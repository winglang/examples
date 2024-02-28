import type { cloud } from "@wingcloud/framework";
import { app } from "./hono";

const mapRequest = (url: string, req: cloud.ApiRequest): Request => {
  return new Request(`${url}${req.path}`, {
    headers: req.headers,
    method: req.method,
  });
}

const mapResponse = async (res: Response): Promise<cloud.ApiResponse> => {
  let headers: Record<string, string> = {};
  res.headers.forEach((value, name) => {
    headers[name] = value;
  });

  return {
    status: res.status,
    headers,
    body: await res.text(),
  };
}

export const handleRequest = async(url: string, request: cloud.ApiRequest): Promise<cloud.ApiResponse> => {
  const req = mapRequest(url, request);
  const response = await app.fetch(req);
  return mapResponse(response);
}