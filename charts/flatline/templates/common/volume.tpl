{{- define "common.volume" -}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "common.fullnameWithComponent" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  accessModes:
    {{- toYaml .componentValues.persistence.accessModes | nindent 4 }}
  resources:
    requests:
      storage: {{ .componentValues.persistence.size }}
  {{- $storageClass := .componentValues.persistence.storageClassName | default (.global).defaultStorageClass | default "" -}}
  {{- if $storageClass }}
  storageClassName: {{ $storageClass }}
  {{- end }}
{{- end }}
