# S3 Backend Plugin

This guide provides an example of Winglang using a `postSynth` plugin to incorporate an S3 Terraform Backend configuration.

## Overview

Winglang offers support for a range of [compilation hooks](https://www.winglang.io/docs/tools/compiler-plugins).

The [postSynth](https://www.winglang.io/docs/tools/compiler-plugins#postsynth-hook) hook is executed after the artifacts have been synthesized. When compiling to a Terraform-based target, such as `tf-aws`, the hook can access the raw Terraform JSON configuration, facilitating manipulation of the JSON written to the compiled output directory.

## Static Plugin Example

The [plugin.static-backend.js](./plugin.static-backend.js) file manipulates the Terraform configuration to utilize an S3 backend, employing environment variables to supply the S3 backend's bucket name, bucket region, and the key for the state file.

The following environment variables are used:

- `TF_BACKEND_BUCKET`: Specifies the name of the S3 bucket that will store the Terraform state.
- `TF_BACKEND_BUCKET_REGION`: Specifies the region in which the bucket is hosted.
- `TF_BACKEND_STATE_FILE`: Specifies the object key for storing the state file.

Ensure these environment variables are set prior to executing the compilation step.

```bash
wing compile -t tf-aws --plugins=plugin.static-backend.js main.w
```

## Dynamic Plugin Example

The [plugin.dynamic-backend.js](./plugin.dynamic-backend.js) file manipulates the Terraform configuration to use an empty S3 backend block. This ensures Terraform selects the appropriate backend, but it requires specific configuration when running terraform init.

```
wing compile -t tf-aws --plugins=plugin.dynamic-backend.js main.w
```

### CLI Args Configuration

```
terraform init \
  -backend-config="bucket=<mybucket>" \
  -backend-config="region=<myregion>" \
  -backend-config="key=my/state/path/s3/key/terraform.tfstate"
```

### Configuration File

Create a `config.s3.tfbackend` file in the `target/main.tfaws` folder with the following content:

```
bucket = "mybucket"
region = "eu-central-1"
key = "my/state/terraform.tfstate"
```

Then, initialize Terraform with the backend configuration:

```
terraform init --backend-config config.s3.tfbackend
```

## Summary

This approach is applicable for [other available backends](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#available-backends) in Terraform as well.

For additional information, refer to the [official](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) Terraform documentation.

Additionally, consider using the [Wing Github Action](https://github.com/winglang/wing-github-action), which largely abstracts these processes.



