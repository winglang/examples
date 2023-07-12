bring cloud;
bring "cdktf" as cdktf;

let bucketModule = new cdktf.TerraformHclModule(
  source:  "terraform-aws-modules/s3-bucket/aws",
  variables: {
    "bucket_prefix" => "wing-it",
    // the cdktf.Token.asString() function is a workaround for
    // this issue https://github.com/winglang/wing/issues/2597
    "force_destroy" => cdktf.Token.asString(true),
    "versioning" => cdktf.Token.asString({
      enabled: true
    })
  }
);
