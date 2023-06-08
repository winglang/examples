import * as internalFetch from "node-fetch";
import { setupServer } from "msw/node";
import { handlers } from "./test/handlers";

export async function fetch(url, method, body) {
  const response = await internalFetch(url, {
    method,
    body: body ? JSON.stringify(body) : undefined,
    headers: {
      "Content-Type": "application/json"
    }
  });
  const text = await response.text();
  return text;
}

let mockServer = null;

export async function mockFetch() {
  mockServer = setupServer(...handlers);

  mockServer.listen({
    onUnhandledRequest: 'error',
  })
}

export async function resetMocks() {
  mockServer.close()
}