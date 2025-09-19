#!/usr/bin/env bash

set -euo pipefail

CREATE_CA=false
CREATE_CERT=false
BC_PATH=""

usage() {
  cat <<EOF
Usage: ${0##*/} [-ca] [-cert] [-bc PATH] [-h|--help]

Options:
  -ca            Create a new self-signed CA to use to sign the certificate.
  -cert          Create a new certificate signed with the CA to use for serving Flatline.
  -bc PATH       Create a BKSv1 store for the Whisper client. PATH must point to a JAR for a Bouncy Castle provider.
  -h, --help     Show this help and exit.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -ca)
      CREATE_CA=true
      shift
      ;;
    -cert)
      CREATE_CERT=true
      shift
      ;;
    -bc)
      if [[ -n "${2-}" && "${2:0:1}" != "-" ]]; then
        BC_PATH=$2
        shift 2
      else
        echo "Error: -bc requires a PATH argument. PATH must point to a JAR for a Bouncy Castle provider." >&2
        exit 2
      fi
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      echo "Unexpected argument: $1" >&2
      usage
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

if $CREATE_CERT; then
  # Delete previous certificate.
  rm -f wildcard-localhost.pem wildcard-localhost.key.pem wildcard-localhost.csr

  # Create wildcard certificate key and CSR.
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out wildcard-localhost.key.pem
  chmod 600 wildcard-localhost.key.pem
  openssl req -new -key wildcard-localhost.key.pem -out wildcard-localhost.csr -config wildcard-csr.cnf

  # Issue wildcard certificate from CSR with CA.
  openssl x509 -req -in wildcard-localhost.csr -CA ca.pem -CAkey ca.key.pem \
    -out wildcard-localhost.pem -days 3650 -sha256 -extfile wildcard-ext.cnf
fi

if [ -n "$BC_PATH" ]; then
  # Store certificate in a BKSv1 file as expected by the Whisper client.
  keytool -importcert \
    -alias whisper \
    -file wildcard-localhost.pem \
    -keystore whisper.store \
    -storetype BKS \
    -providerclass org.bouncycastle.jce.provider.BouncyCastleProvider \
    -providerpath "$BC_PATH" \
    -storepass whisper
fi
