# Simple Stock Poller

This is an example for a simple stock polling application, that retrieves data from [Twelve Data API](https://twelvedata.com/), stores the latest stock price in DynamoDB and publishes the update to a SQS queue.

![Overview](./overview.png)

It show case the capabilities of Wing to fetch data from an external API and distribute this across different systems.

![Sequence Diagram](./sequence-diagram.png)

## Prerequisite

Please make sure to use a current and working setup of the [wing cli](https://docs.winglang.io/getting-started/installation)

## Usage

As the Scheduler component is only available with the `sim` and `tf-aws` provider, you do have to compile and then deploy the application.
For more details see also [Wing compatability matrix](https://www.winglang.io/docs/standard-library/compatibility-matrix).

### Wing Console

```
wing it
```

### Wing compile

```
wing compile --target tf-aws stock-poller.w
```

### Wing deploy

```
cd target/stock-updates.tfaws
```

For your first deployment you have to initialize Terraform in the working directory:
```
terraform init
```

Afterwards you can deploy the project:
```
terraform apply
```
