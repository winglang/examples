// copied from here https://github.com/winglang/wing-github-action/blob/c0a37fd14067ab356791cfdcbc77ee59ba2561fa/actions/deploy/plugins/backend.s3.js
/**
 *    - TF_BACKEND_BUCKET - The name of the s3 bucket to use for storing Terraform state
 *    - TF_BACKEND_BUCKET_REGION - The region the bucket was deployed to
 *    - STATE_FILE - The object key used to store state file
 *
 * This plugin will configure the backend to use S3 for storing state. The configuration
 * is static and will not change based on the environment.
 *
 */

exports.postSynth = function(config) {
  if (!process.env.TF_BACKEND_BUCKET) {throw new Error("env var TF_BACKEND_BUCKET not set")}
  if (!process.env.TF_BACKEND_BUCKET_REGION) {throw new Error("env var TF_BACKEND_BUCKET_REGION not set")}
  if (!process.env.TF_BACKEND_STATE_FILE) {throw new Error("env var TF_BACKEND_STATE_FILE not set")}
  config.terraform.backend = {
    s3: {
      bucket: process.env.TF_BACKEND_BUCKET,
      region: process.env.TF_BACKEND_BUCKET_REGION,
      key: process.env.TF_BACKEND_STATE_FILE
    }
  }
  return config;
}