#!/usr/bin/env bash

set -xeuo pipefail
npm install
npx tsc platform/index.ts
wing test --no-analytics --no-update-check --platform tf-aws --platform ./platform/index.js main.w