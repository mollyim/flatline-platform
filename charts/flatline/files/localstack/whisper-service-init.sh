#!/usr/bin/env bash
set -e

awslocal cloudformation deploy \
  --stack-name whisper-service \
  --template-file /opt/whisper-service-aws-cloudformation.yaml

awslocal s3 cp /opt/whisper-service-dynamic-config-dev.yaml s3://whisper-service-dynamic-config/dev.yml
