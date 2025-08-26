{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.labels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .componentName }}
app.kubernetes.io/component: {{ .componentName }}
{{- end }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "common.fullnameWithComponent" -}}
{{- $base := include "common.fullname" . -}}
{{- printf "%s-%s" $base .componentName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configMapFilesChecksum" -}}
{{- $dataFiles := .componentValues.configMapFiles.data }}
{{- $binDataFiles  := .componentValues.configMapFiles.binaryData }}
{{- $contents := "" }}
{{- $dataKeys := keys $dataFiles | sortAlpha }}
{{- range $i, $key := $dataKeys }}
  {{- $path := index $dataFiles $key }}
  {{- $raw  := $.Files.Get $path }}
  {{- $contents = printf "%s\n%s" $contents $raw }}
{{- end }}
{{- $binDataKeys := keys $binDataFiles | sortAlpha }}
{{- range $i, $key := $binDataKeys }}
  {{- $path := index $binDataFiles $key }}
  {{- $raw  := $.Files.Get $path | b64enc }}
  {{- $contents = printf "%s\n%s" $contents $raw }}
{{- end }}
{{- ($contents | sha256sum) | substr 0 62  }}
{{- end }}
