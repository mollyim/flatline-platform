{{- define "common.job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "common.fullnameWithComponent" . }}-{{ .componentValues.job.name | default "init" }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  backoffLimit: {{ .componentValues.job.backoffLimit | default "6" }}
  template:
    spec:
      serviceAccountName: {{ .componentValues.job.serviceAccountName | default "default" }}
      restartPolicy: {{ .componentValues.job.restartPolicy | default "Never" }}
      containers:
        - name: {{ .componentValues.job.name | default "init" }}
          {{- if .componentValues.job.image }}
          image: {{ .componentValues.job.image.repository }}:{{ .componentValues.job.image.tag }}
          imagePullPolicy: {{ .componentValues.job.image.pullPolicy | default .componentValues.image.pullPolicy }}
          {{- else }}
          image: {{ .componentValues.image.repository }}:{{ .componentValues.image.tag }}
          imagePullPolicy: {{ .componentValues.image.pullPolicy }}
          {{- end }}
          {{- if .componentValues.job.command }}
          command:
            - {{ quote .componentValues.job.command }}
          {{- if .componentValues.job.args }}
          args: 
            {{- range $arg := .componentValues.job.args }}
            {{- $rendered := tpl $arg $ }}
            - {{ quote $rendered }}
            {{- end }}
          {{- end }}
          {{- end }}
{{- end }}
