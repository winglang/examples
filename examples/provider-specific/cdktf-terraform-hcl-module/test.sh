#!/usr/bin/env bash

set -xeuo pipefail
npm install
wing test --no-analytics --no-update-check --platform tf-aws main.w