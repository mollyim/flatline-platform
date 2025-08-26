{{- define "common.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include "common.fullnameWithComponent" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  type: {{ .componentValues.service.type }}
  ports:
    {{- range $name, $p := .componentValues.service.ports }}
    - port: {{ $p.port }}
      targetPort: {{ $p.targetPort | default $p.port }}
      protocol: {{ $p.protocol }}
      name: {{ $name }}
    {{- end }}
  selector:
    {{- include "common.labels" . | nindent 4 }}
{{- end }}
