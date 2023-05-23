bring "cdktf" as cdktf;

let provider = new cdktf.TerraformHclModule(
    source:  "github.com/philips-labs/terraform-aws-github-oidc?ref=0.7.0//modules/provider"
);

let github_oidc = new cdktf.TerraformHclModule(
    source:  "github.com/philips-labs/terraform-aws-github-oidc?ref=0.7.0",
    variables: {
        openid_connect_provider_arn: provider.get("arn"),
        repo: "winglang/examples",
        role_name: "repo-examples",
        conditions: [{
            test: "StringLike",
            variable: "token.actions.githubusercontent.com:sub",
            values: cdktf.Token.asString(["repo:my-org/my-repo:pull_request"])
        }]
    }
) as "repo-examples";