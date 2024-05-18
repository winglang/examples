#!/usr/bin/env bash

set -xeuo pipefail

trap 'catch_error' ERR

function catch_error() {
    echo "Error occurred. Running 'npx cdk destroy'..."
    npx cdk destroy --force
}

npm install
VERSION=$(npm list aws-cdk | grep aws-cdk@ | cut -d'@' -f2); npm install -g "aws-cdk-lib@$VERSION"
npx cdk deploy --require-approval never --outputs-file outputs.json
npx cdk destroy --force