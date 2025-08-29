{{- define "common.configMap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "common.fullnameWithComponent" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
{{- if .componentValues.configMap.data }}
data:
  {{- range $key, $data := .componentValues.configMap.data }}
  {{ $key }}: |-
    {{- tpl $data $ | nindent 4 }}
  {{- end }}
{{- end -}}
{{- if .componentValues.configMap.binaryData }}
binaryData:
  {{- range $key, $data := .componentValues.configMap.binaryData }}
  {{ $key }}: |-
    {{- tpl $data $ | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end -}}
