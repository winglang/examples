import nodeFetch from "node-fetch";
import { setupServer } from "msw/node";
import { handlers } from "./test/handlers";

export async function fetch(url, method, body) {
  const response = await nodeFetch(url, {
    method,
    body: body ? JSON.stringify(body) : undefined,
    headers: {
      "Content-Type": "application/json"
    }
  });

  console.log({response});
  const json = await response.json();
  console.log({json});
  return json;
}

let mockServer = null;

export async function mockFetch() {
  mockServer = setupServer(...handlers);

  mockServer.listen({
    onUnhandledRequest: 'bypass',
  })
}

export async function resetMocks() {
  mockServer.close()
}