{{- define "common.deployment" -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullnameWithComponent" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
spec:
  replicas: {{ .componentValues.replicas }}
  selector:
    matchLabels:
      {{- include "common.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "common.labels" . | nindent 8 }}
      annotations:
        {{- if .componentValues.configMap }}
        checksum/config: {{ include "common.configMapChecksum" . }}
        {{- end }}
        {{- if .componentValues.secret }}
        checksum/secret: {{ include "common.secretChecksum" . }}
        {{- end }}
    spec:
      initContainers:
      {{- if .componentValues.waitForComponents }}
        - name: wait-for-components
          image: {{ .Values.common.defaultInitContainer.image.repository }}:{{ .Values.common.defaultInitContainer.image.tag }}
          imagePullPolicy: {{ .Values.common.defaultInitContainer.image.pullPolicy }}
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
      {{- if .componentValues.initContainer }}
        - name: {{ .componentValues.initContainer.name | default "init" }}
          {{- if .componentValues.initContainer.image }}
          image: {{ .componentValues.initContainer.image.repository }}:{{ .componentValues.initContainer.image.tag }}
          imagePullPolicy: {{ .componentValues.initContainer.image.pullPolicy | default .Values.common.defaultInitContainer.image.pullPolicy }}
          {{- else }}
          image: {{ .Values.defaultInitContainer.image.repository }}:{{ .Values.defaultInitContainer.image.tag }}
          imagePullPolicy: {{ .Values.common.defaultInitContainer.image.pullPolicy }}
          {{- end }}
          {{- if .componentValues.initContainer.command }}
          command:
            - {{ quote .componentValues.initContainer.command }}
          {{- if .componentValues.initContainer.args }}
          args:
            {{- range $arg := .componentValues.initContainer.args }}
            {{- $rendered := tpl $arg $ }}
            - {{ quote $rendered }}
            {{- end }}
          {{- end }}
          {{- end }}
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
            {{- else if $vm.secret }}
            {{- range $vm.secret.items }}
            - name: {{ $vm.name }}
              mountPath: {{ .mountPath }}
              subPath: {{ .path }}
              {{- if .readOnly }}
              readOnly: true
              {{- end }}
            {{- end }}
            {{- else if $vm.persistentVolumeClaim }}
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
          {{- else if .secret }}
          secret:
            secretName: {{ tpl .secret.name $ }}
            {{- if .secret.defaultMode }}
            defaultMode: {{ .secret.defaultMode }}
            {{- end }}
            {{- if .secret.items }}
            items:
              {{- range .secret.items }}
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
