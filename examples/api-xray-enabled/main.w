bring cloud;
bring util;
bring http;
bring expect;

let api = new cloud.Api();

api.get("/hello", inflight (req) => {
  return {
    status: 200,
    headers: {
      "Content-Type" => "text/plain"
    },
    body: "hello world"
  };
});


test "it should respond with 200" {
  let response = http.get("{api.url}/hello");
  expect.equal(response.status, 200);
}
