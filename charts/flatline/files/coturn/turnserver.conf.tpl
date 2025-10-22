listening-port=3478
tls-listening-port=5349

lt-cred-mech
realm=flatline
user=flatline:flatline

fingerprint

listening-ip=0.0.0.0
relay-ip=0.0.0.0
external-ip={{ .Values.global.advertisedAddress }}

min-port=30000
max-port=40000

verbose
