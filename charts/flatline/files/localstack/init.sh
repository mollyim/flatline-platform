#!/usr/bin/env bash
set -e

awslocal cloudformation deploy \
  --stack-name flatline \
  --template-file /opt/flatline-resources.yaml

awslocal s3 cp /opt/whisper-service-dynamic-config-dev.yaml s3://whisper-service-dynamic-config/dev.yml
