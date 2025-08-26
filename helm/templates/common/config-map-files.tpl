{{- define "common.configMapFiles" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullnameWithComponent" . }}-files
  labels:
    {{- include "common.labels" . | nindent 4 }}
{{- if .componentValues.configMapFiles.data }}
data:
  {{- range $key, $data := .componentValues.configMapFiles.data }}
  {{ $key }}: |-
    {{- tpl $data $ | nindent 4 }}
  {{- end }}
{{- end -}}
{{- if .componentValues.configMapFiles.binaryData }}
binaryData:
  {{- range $key, $data := .componentValues.configMapFiles.binaryData }}
  {{ $key }}: |-
    {{- tpl $data $ | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end -}}
