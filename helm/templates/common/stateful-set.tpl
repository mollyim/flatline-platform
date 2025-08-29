{{- define "common.statefulSet" -}}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ include "common.fullnameWithComponent" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  replicas: {{ .componentValues.replicas }}
  selector:
    matchLabels:
      {{- include "common.labels" . | nindent 6 }}
  serviceName: {{ include "common.fullnameWithComponent" . }}
  template:
    metadata:
      labels:
        {{- include "common.labels" . | nindent 8 }}
      annotations:
        {{- if .componentValues.configMapFiles }}
        checksum/config: {{ include "common.configMapFilesChecksum" . }}
        {{- end }}
    spec:
      containers:
        - name: {{ .componentName }}
          image: {{ .componentValues.image.repository }}:{{ .componentValues.image.tag }}
          imagePullPolicy: {{ .componentValues.image.pullPolicy }}
          {{- if .componentValues.container }}
          {{- if .componentValues.container.command }}
          command:
            - {{ quote .componentValues.container.command }}
          {{- if .componentValues.container.args }}
          args: 
            {{- range $arg := .componentValues.container.args }}
            {{- $rendered := tpl $arg $ }}
            - {{ quote $rendered }}
            {{- end }}
          {{- end }}
          {{- end }}
          {{- end }}
          {{- if .componentValues.service }}
          ports:
          {{- range $name, $p := .componentValues.service.ports }}
            - name: {{ $name }}
              containerPort: {{ $p.targetPort | default $p.port }}
          {{- end }}
          {{- end }}
          {{- if .componentValues.volumeMounts }}
          volumeMounts:
            {{- range $vm := .componentValues.volumeMounts }}
            {{- if $vm.configMap }}
            {{- range $vm.configMap.items }}
            - name: {{ $vm.name }} 
              mountPath: {{ .mountPath }}
              subPath: {{ .path }}
              {{- if .readOnly }}
              readOnly: true
              {{- end }}
            {{- end }}
            {{- else }}
            - name: {{ $vm.name }}
              mountPath: {{ $vm.mountPath }}
              {{- if $vm.subPath }}
              subPath: {{ $vm.subPath }}
              {{- end }}
              {{- if $vm.readOnly }}
              readOnly: true
              {{- end }}
            {{- end }}
            {{- end }}
          {{- end }}
      volumes:
        {{- range .componentValues.volumeMounts }}
        - name: {{ .name }}
          {{- if .configMap }}
          configMap:
            name: {{ tpl .configMap.name $ }}
            {{- if .configMap.defaultMode }}
            defaultMode: {{ .configMap.defaultMode }}
            {{- end }} 
            {{- if .configMap.items }}
            items:
              {{- range .configMap.items }}
              - key: {{ .key }}
                path: {{ .path }}
              {{- end }}
            {{- end }}
          {{- else if .persistentVolumeClaim }}
          persistentVolumeClaim:
            claimName: {{ tpl .persistentVolumeClaim.claimName $ }}
          {{- end }}
        {{- end }}
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes:
          {{- toYaml .componentValues.persistence.accessModes | nindent 10 }}
        resources:
          requests:
            storage: {{ .componentValues.persistence.size }}
        {{- $storageClass := .componentValues.persistence.storageClassName | default (.global).defaultStorageClass | default "" -}}
        {{- if $storageClass }}
        storageClassName: {{ $storageClass }}
        {{- end }}
  podManagementPolicy: {{ .componentValues.podManagementPolicy | default "Parallel" }}
{{- end }}
