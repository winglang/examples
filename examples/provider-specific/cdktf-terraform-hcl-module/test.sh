#!/usr/bin/env bash

set -xeuo pipefail
npm install
wing test --no-analytics --no-update-check --snapshots=deploy --platform tf-aws main.w
