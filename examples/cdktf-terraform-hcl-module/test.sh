#!/usr/bin/env bash

set -xeuo pipefail
npm install
wing test -t tf-aws main.w