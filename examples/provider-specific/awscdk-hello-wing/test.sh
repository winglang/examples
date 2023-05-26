#!/usr/bin/env bash

set -xeuo pipefail

trap 'catch_error' ERR

function catch_error() {
    echo "Error occurred. Running 'npx cdk destroy'..."
    npx cdk destroy --force --app "./target/main.awscdk"
}

export CDK_STACK_NAME="hello-wing-test"
npm install
wing compile -t awscdk main.w
npx cdk deploy --require-approval never --outputs-file outputs.json --app "./target/main.awscdk"
npx cdk destroy --force --app "./target/main.awscdk"