#!/bin/bash

# Delete previous root CA.
# rm ca.pem ca.key.pem ca.cer ca.srl
# Create root CA.
# openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out ca.key.pem
# chmod 600 ca.key.pem
# openssl req -x509 -new -nodes -key ca.key.pem -sha256 -days 3650 -out ca.pem -config ca.cnf

# Delete previous certificate.
rm wildcard-localhost.pem wildcard-localhost.key.pem wildcard-localhost.cer
# Create wildcard certificate key and CSR.
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out wildcard-localhost.key.pem
chmod 600 wildcard-localhost.key.pem
openssl req -new -key wildcard-localhost.key.pem -out wildcard-localhost.csr -config wildcard-csr.cnf

# Issue wildcard certificate from CSR with CA.
openssl x509 -req -in wildcard-localhost.csr -CA ca.pem -CAkey ca.key.pem -CAcreateserial \
  -out wildcard-localhost.pem -days 3650 -sha256 -extfile wildcard-ext.cnf

# Generate CA DER file for use with "libsignal". 
openssl x509 -in ca.pem -outform der -out ca.cer
