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

{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .componentName }}
app.kubernetes.io/component: {{ .componentName }}
{{- end }}
{{- end -}}

{{- define "common.labels" -}}
{{- include "common.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "common.fullnameWithComponent" -}}
{{- $base := include "common.fullname" . -}}
{{- printf "%s-%s" $base .componentName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.configMapChecksum" -}}
{{- $config := .componentValues.configMap }}
{{- $collect := list }}
{{- $sections := list (dict "m" $config.data) (dict "m" $config.binaryData) }}
{{- range $s := $sections }}
  {{- with $m := $s.m }}
    {{- $keys := keys $m | sortAlpha }}
    {{- range $i, $k := $keys }}
      {{- $val := index $m $k }}
      {{- $rendered := tpl $val $ }}
      {{- $collect = append $collect (printf "%s" $rendered) }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $contents := join "\n" $collect }}
{{- printf "%s" ($contents | sha256sum | substr 0 62) }}
{{- end }}

{{- define "common.secretChecksum" -}}
{{- $secret := .componentValues.secret }}
{{- $collect := list }}
{{- $sections := list (dict "m" $secret.data) (dict "m" $secret.stringData) (dict "m" $secret.binaryData) }}
{{- range $s := $sections }}
  {{- with $m := $s.m }}
    {{- $keys := keys $m | sortAlpha }}
    {{- range $i, $k := $keys }}
      {{- $val := index $m $k }}
      {{- $rendered := tpl $val $ }}
      {{- $collect = append $collect (printf "%s" $rendered) }}
    {{- end }}
  {{- end }}
{{- end }}
{{- $contents := join "\n" $collect }}
{{- printf "%s" ($contents | sha256sum | substr 0 62) }}
{{- end }}
