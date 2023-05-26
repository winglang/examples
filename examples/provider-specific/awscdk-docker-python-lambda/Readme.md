# Docker based AWS Lambda Function for the AWS CDK Target

This isn't leveraging the Wing SDK, but using Constructs from the AWS CDK directly via [bring](https://docs.winglang.io/reference/spec#4-module-system). That's why the [package.json](./package.json) file is present and referencing the `aws-cdk-lib` package.

This is largely based on an example by [Marcio Cruz](https://github.com/marciocadev) who contributed the AWS CDK provider for wing.

## Prerequisite

Please make sure to use a current and working setup of the [wing cli](https://docs.winglang.io/getting-started/installation).

## Usage

### Setup

Nb: In case of a globally installed Wing CLI, the `aws-cdk-lib` package needs to be installed globally as well. See this [issue](https://github.com/winglang/wing/issues/2478) for more details.

```
npm install
```

### Wing Console

As of May 2023 the Wing Console is not yet supported.

### Wing Tests

As of May 2023 tests are not yet supported out of the box

### Deploy

```
export CDK_STACK_NAME="wing-docker-python-lambda"
wing compile -t awscdk main.w
npx cdk deploy --app "./target/main.awscdk"
```