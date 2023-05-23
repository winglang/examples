bring "aws-cdk-lib" as awscdk;

class CdkDockerImageFunction {
    function:  awscdk.aws_lambda.DockerImageFunction;

    init() {
        this.function = new awscdk.aws_lambda.DockerImageFunction(awscdk.aws_lambda.DockerImageFunctionProps{
            code: awscdk.aws_lambda.DockerImageCode.fromImageAsset("./container"),
        }) as "DockerImageFunction";
    }
}

new CdkDockerImageFunction();

// policy.attachToRole(provider.role);

// class AwsGithubOIDC  {
//     provider: cdkp.GitHubActionRole;

//     init() {
//       this.provider = new cdkp.GitHubActionRole(
//         repos: [
//           "winglang/wing",
//         ],
//       );

//       let policy = new aws.aws_iam.Policy(
//         statements: [
//           new aws.aws_iam.PolicyStatement(
//             actions: ["*"],
//             resources: ["*"],
//           ),
//         ],
//       );

//       policy.attachToRole(this.provider.role);
//     }
// }

// new AwsGithubOIDC ();