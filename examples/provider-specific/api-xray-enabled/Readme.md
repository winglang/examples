# HTTP API with X-Ray and Lambda OpenTelemetry

This is a [HTTP API](https://www.winglang.io/docs/standard-library/cloud/api) example where both the API Gateway and Lambda handlers are enabled with X-Ray. It's using [aws-otel](https://aws-otel.github.io/) for most of the heavy lifting.

Each Lambda Handler will have OpenTelemetry config injected, without changing any code or adding aws-xray sdks. This works by adding an OpenTelemetry Lambda Layer, which unfortunately adds a bit of cold start time (500ms - 1s).

This works by defining a custom [platform](./platform.ts) for AWS as described [here](https://www.winglang.io/docs/concepts/platforms#custom-platforms).

This got extracted from building internal tools for [wing.cloud](https://wing.cloud).

![diagram](./diagram.png)

## Prerequisite

Please make sure to use a current and working setup of the [wing cli](https://docs.winglang.io/getting-started/installation)

## Usage

### Wing Console

```
wing it
```

### Wing Tests

```
wing test --debug  main.w
```
