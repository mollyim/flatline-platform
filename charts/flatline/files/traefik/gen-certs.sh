#!/bin/bash

set -euo pipefail

CREATE_CA=false

while (( "$#" )); do
  case "$1" in
    -ca) CREATE_CA=true; shift ;;
    -h|--help)
      echo "Usage: $0 [-ca]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

if $CREATE_CA; then
  # Delete previous root CA.
  rm -f ca.pem ca.key.pem ca.cer ca.srl

  # Create root CA.
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out ca.key.pem
  chmod 600 ca.key.pem
  openssl req -x509 -new -nodes -key ca.key.pem -sha256 -days 3650 -out ca.pem -config ca.cnf

  # Generate CA DER file. 
  openssl x509 -in ca.pem -outform der -out ca.cer
fi

# Delete previous certificate.
rm -f wildcard-localhost.pem wildcard-localhost.key.pem wildcard-localhost.csr

# Create wildcard certificate key and CSR.
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out wildcard-localhost.key.pem
chmod 600 wildcard-localhost.key.pem
openssl req -new -key wildcard-localhost.key.pem -out wildcard-localhost.csr -config wildcard-csr.cnf

# Issue wildcard certificate from CSR with CA.
openssl x509 -req -in wildcard-localhost.csr -CA ca.pem -CAkey ca.key.pem \
  -out wildcard-localhost.pem -days 3650 -sha256 -extfile wildcard-ext.cnf
