set -e
port={{ .componentValues.service.ports.default.port }}
ADDRS=""
for i in $(seq 0 {{ add .componentValues.replicas -1 }}); do
  pod={{ include "common.fullnameWithComponent" . }}-$i
  echo "Waiting for $pod to become ready..."
  until getent hosts $pod.{{ include "common.fullnameWithComponent" . }}.{{ .Release.Namespace }}.svc.cluster.local \
    >/dev/null 2>&1; do sleep 1; done
  until redis-cli -h $pod.{{ include "common.fullnameWithComponent" . }}.{{ .Release.Namespace }}.svc.cluster.local \
    -p {{ .componentValues.service.ports.default.port }} PING \
    >/dev/null 2>&1; do sleep 1; done
  ADDRS="$ADDRS $pod.{{ include "common.fullnameWithComponent" . }}.{{ .Release.Namespace }}.svc.cluster.local:$port"
done
echo "yes" | redis-cli --cluster create $ADDRS --cluster-replicas {{ .componentValues.cluster.replicasPerMaster }}
