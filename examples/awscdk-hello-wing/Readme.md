# Hello Wing for the AWS CDK Target

The example from the [getting started](https://docs.winglang.io/getting-started/hello) guide.

This is a simple example of a WingLang project that demonstrates the usage of cloud services. The program creates a cloud bucket and a cloud queue. It then adds a consumer to the queue, which writes a message to a file in the bucket.

![diagram](./diagram.png)

## Prerequisite

Please make sure to use a current and working setup of the [wing cli](https://docs.winglang.io/getting-started/installation)

## Usage

### Setup

Nb: In case of a globally installed Wing CLI, the `aws-cdk-lib` package needs to be installed globally as well. See this [issue](https://github.com/winglang/wing/issues/2478) for more details.

```
npm install
```

### Wing Console

```
wing it
```

### Wing Tests

As of May 2023 tests are currently not yet supported out of the box

### Deploy

```
export CDK_STACK_NAME="hello-wing"
wing compile -t awscdk main.w
npx cdk deploy --app "./target/main.awscdk"
```