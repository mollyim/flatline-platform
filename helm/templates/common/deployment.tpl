{{- define "common.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullnameWithComponent" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  replicas: {{ .componentValues.replicaCount }}
  selector:
    matchLabels:
      {{- include "common.labels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "common.labels" . | nindent 8 }}
      annotations:
        {{- if .componentValues.configMapFiles }}
        checksum/config: {{ include "common.configMapFilesChecksum" . }}
        {{- end }}
    spec:
      initContainers:
      {{- if .componentValues.waitForComponents }}
        - name: wait-for-components
          image: {{ .Values.common.waitForComponentsInitContainer.image.repository }}:{{ .Values.common.waitForComponentsInitContainer.image.tag }}
          imagePullPolicy: {{ .Values.common.waitForComponentsInitContainer.image.pullPolicy }}
          command:
            - /bin/sh
            - -c
            - |
              set -e
              {{- range $svcName, $svc := .componentValues.waitForComponents }}
              echo 'Waiting for component "{{ $svcName }}" at "{{ tpl $svc.host $ }}:{{ tpl $svc.port $ }}"...'
              until nc -z -v -w5 {{ tpl $svc.host $ }} {{ tpl $svc.port $ }}; do
                echo 'Still waiting for "{{ $svcName }}"...'
                sleep 2
              done
              echo 'Component "{{ $svcName }}" is up!'
              {{- end }}
          resources:
            limits:
              cpu: 100m
              memory: 128Mi
            requests:
              cpu: 50m
              memory: 64Mi
      {{- end }}
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
              {{- end -}}
            {{- end -}}
            {{- else if $vm.persistentVolumeClaim }}
            - name: {{ $vm.name }}
              mountPath: {{ $vm.mountPath }}
              {{- if $vm.readOnly }}
              readOnly: true
              {{ end }}
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
          env:
            {{- range .componentValues.env }}
            - name: {{ .name }}
              value: {{ quote (tpl .value $) }}
            {{- end }}
          {{- if .componentValues.startupProbe }}
          startupProbe:
            initialDelaySeconds: {{ .componentValues.startupProbe.initialDelaySeconds }}
            periodSeconds:       {{ .componentValues.startupProbe.periodSeconds }}
            timeoutSeconds:      {{ .componentValues.startupProbe.timeoutSeconds }}
            failureThreshold:    {{ .componentValues.startupProbe.failureThreshold }}
            {{- if .componentValues.startupProbe.exec }}
            exec:
              command:
                {{- range $arg := .componentValues.startupProbe.exec.command }}
                {{- $rendered := tpl $arg $ }}
                - {{ quote $rendered }}
                {{- end }}
            {{- else if .componentValues.startupProbe.tcpSocket }}
            tcpSocket:
              port: {{ tpl .componentValues.startupProbe.tcpSocket.port . }}
            {{- else if .componentValues.startupProbe.httpGet }}
            httpGet:
              path:   {{ .componentValues.startupProbe.httpGet.path }}
              port:   {{ tpl .componentValues.startupProbe.httpGet.port . }}
              scheme: {{ .componentValues.startupProbe.httpGet.scheme }}
            {{- end }}
          {{- end }}
      {{- if .componentValues.volumeMounts }}
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
      {{- end }}
{{- end }}
