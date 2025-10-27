no-tls
no-dtls

listening-port=3478
min-port=49152
max-port=65535

external-ip={{ .Values.global.advertisedAddress }}

realm=turn.{{ .Values.global.hostname }}
use-auth-secret
# This secret must match the one configured in Whisper for Coturn.
static-auth-secret=c2c73aaf192e0f7d4dd7635b0a283388632c345b

fingerprint

new-log-timestamp
verbose
