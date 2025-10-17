listening-port=3478
tls-listening-port=5349

lt-cred-mech
realm=flatline
user=flatline:flatline

relay-threads=0
external-ip={{ .Values.global.advertisedAddress }}

min-port=30000
max-port=60000

verbose
