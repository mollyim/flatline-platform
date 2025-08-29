{{- define "common.secret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.fullnameWithComponent" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
type: {{ .componentValues.secret.type | default "Opaque" }}
{{- if .componentValues.secret.data }}
data:
  {{- range $key, $data := .componentValues.secret.data }}
  {{ $key }}: |-
    {{- tpl $data $ | nindent 4 }}
  {{- end }}
{{- end -}}
{{- if .componentValues.secret.stringData }}
stringData:
  {{- range $key, $data := .componentValues.secret.stringData }}
  {{ $key }}: |-
    {{- tpl $data $ | nindent 4 }}
  {{- end }}
{{- end -}}
{{- if .componentValues.secret.binaryData }}
binaryData:
  {{- range $key, $data := .componentValues.secret.binaryData }}
  {{ $key }}: |-
    {{- tpl $data $ | nindent 4 }}
  {{- end }}
{{- end -}}
{{- end -}}
