import { App, Function } from '@winglang/sdk/lib/target-tf-aws';
import { Effect } from '@winglang/sdk/lib/shared-aws';
import { Construct } from 'constructs';

export class EnableXray {
  constructor(private app: App) {}

  isApiGatewayStage(node: Construct): boolean {
    return node && (node as any)["terraformResourceType"] === 'aws_api_gateway_stage';
  }

  isLambdaFunction(node: Construct): boolean {
    return node && (node as any)['function'] && (node as any)['function']['terraformResourceType'] === 'aws_lambda_function';
  }

  enableXrayForApiGateway(node: Construct) {
    (node as any).addOverride('xray_tracing_enabled', true);
  }

  enableXrayForLambda(node: Construct) {
    const cloudFunction = node as Function;
    const lambdaArchitecture = "arm64"
    const region = this.app.region;
    const version = "1-17-1:1"
    const lambdaLayer = `arn:aws:lambda:${region}:901920570463:layer:aws-otel-nodejs-${lambdaArchitecture}-ver-${version}`
    cloudFunction.addPolicyStatements({
      effect: Effect.ALLOW,
      actions: [
        'xray:PutTraceSegments',
        'xray:PutTelemetryRecords',
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets",
        "xray:GetSamplingStatisticSummaries",
      ],
      resources: ['*']
    })

    cloudFunction.addEnvironment('AWS_LAMBDA_EXEC_WRAPPER', '/opt/otel-handler')

    const cdktfFunction = cloudFunction['function'];

    cdktfFunction.putTracingConfig({
      mode: 'Active'
    });

    cdktfFunction.memorySize = 1024;

    cdktfFunction.layers = [lambdaLayer];
  }

  visit(node: Construct) {
    if (this.isApiGatewayStage(node)) {
      this.enableXrayForApiGateway(node);
    }
    if (this.isLambdaFunction(node)) {
      this.enableXrayForLambda(node);
    }
  }
}
