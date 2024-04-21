# Docker based AWS Lambda Function for the AWS CDK Target

This isn't leveraging the Wing SDK, but using Constructs from the AWS CDK directly via [bring](https://docs.winglang.io/reference/spec#4-module-system). That's why the [package.json](./package.json) file is present and referencing the `aws-cdk-lib` package.

This is largely based on an example by [Marcio Cruz](https://github.com/marciocadev) who contributed the AWS CDK provider for wing.

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
