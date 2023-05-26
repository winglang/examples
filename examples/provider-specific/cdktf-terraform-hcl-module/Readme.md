# Using a Terraform HCL Module

This demonstrates how any existing Terraform [module](https://developer.hashicorp.com/terraform/language/modules/sources) can be used as part of a Wing application.

![diagram](./diagram.png)

## Prerequisite

Please make sure to use a current and working setup of the [wing cli](https://docs.winglang.io/getting-started/installation)

## Usage

Since this is not using the Wing SDK, it needs to be tested via the `tf-aws` target.

### Wing Console

This will show you the diagram, but there's no interaction possible.

```
wing it
```

### Wing Tests

```
wing test -t tf-aws --debug  main.w
```
