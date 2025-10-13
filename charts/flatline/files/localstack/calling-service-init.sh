#!/usr/bin/env bash
set -e

awslocal cloudformation deploy \
  --stack-name calling-service \
  --template-file /opt/calling-service-aws-cloudformation.yaml
