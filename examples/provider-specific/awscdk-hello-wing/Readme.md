# Hello Wing for the AWS CDK Target

The example from the [getting started](https://www.winglang.io/docs/start-here/hello) guide.

This is a simple example of a Wing project that demonstrates the usage of cloud services. The
program creates a cloud bucket and a cloud queue. It then adds a consumer to the queue, which writes
a message to a file in the bucket.

This project is using the [AWS CDK target platform](https://www.winglang.io/docs/platforms/awscdk).

![diagram](./diagram.png)

## Prerequisite

Please make sure to use a current and working setup of the [Wing
CLI](https://docs.winglang.io/getting-started/installation)

## Usage

### Setup

```sh
npm install
```

### Wing Simulator

```sh
wing it
```

### Bootstrap

Before the first deployment to an AWS environment (account/region), you'll need to bootstrap some CDK resources:

```sh
npx cdk bootstrap
```

### Deploy

```sh
npx cdk deploy
```
