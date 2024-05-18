{{- define "web_domain" }}
    {{- if .Values.web_domain }}
        {{- .Values.web_domain }}
    {{- else }}
        {{- printf "%s.creaty.club" .Release.Name }}
    {{- end }}
{{- end }}

{{- define "api_domain" }}
    {{- if .Values.api_domain }}
        {{- .Values.api_domain }}
    {{- else }}
        {{- printf "%s-api.creaty.club" .Release.Name }}
    {{- end }}
{{- end }}

{{- define "api_image" -}}
{{ .Values.api.image.reference }}:{{ tpl .Values.api.image.tag . }}
{{- end }}

{{- define "web_image" -}}
{{ .Values.nginx.init.web.image.reference }}:{{ tpl .Values.nginx.init.web.image.tag . }}
{{- end }}

{{- define "platform_image" -}}
{{ .Values.platform.image.reference }}:{{ tpl .Values.platform.image.tag . }}
{{- end }}

{{- define "configmap" }}
{{- range $name, $config := .configs }}
  {{ $name }}: |
    {{- (tpl $config.value (merge $._ (dict "_vars" $.vars))) | trim | nindent 4 }}
{{- end }}
{{- end }}

{{- define "configs" }}
{{- range $name, $config := . }}
- name: configs
  mountPath: {{ $config.path }}
  subPath: {{ $name }}
{{- end }}
{{- end -}}

{{- define "env" }}
{{- range $name, $value := .envs }}
  {{- if and (kindIs "map" $value) (hasKey $value "secret") }}
- name: {{ $name }}
  valueFrom:
    secretKeyRef:
      name: {{ $value.secret }}
      key: {{ default $name $value.key }}
  {{- end }}
{{- end }}
{{- range $name, $value := .envs }}
  {{- if not (and (kindIs "map" $value) (hasKey $value "secret")) }}
- name: {{ $name }}
  value: {{ quote (tpl $value $._) }}
  {{- end }}
{{- end }}
{{- end -}}

{{- define "ports" }}
{{- range $name, $port := . }}
- name: {{ $name }}
  containerPort: {{ $port }}
{{- end }}
{{- end }}

{{- define "init-wait-for-redis" }}
- name: wait-for-{{ .redis_host }}
  image: {{ .redis_image | default "redis:alpine" }}
  command:
    - sh
    - -c
    - |
      retries=0
      max_retries={{ .retries | default 20 }}
      timeout={{ .timeout | default 3 }}
      while [ "$retries" -lt "$max_retries" ]; do
        retries=$((retries + 1))
        echo "Attempt $retries of $max_retries"
        if redis-cli -h {{ .redis_host }} -p {{ .redis_port | default 6379 }} ping; then
          exit 0
        else
          echo "Failed to connect to Redis, retrying in $timeout seconds..."
          sleep "$timeout"
        fi
      done
      echo "Failed to connect to Redis after $max_retries retries, exiting"
      exit 1
{{- end }}

{{- define "init-wait-for-postgres" }}
- name: wait-for-{{ .postgres_host }}
  image: {{ .postgres_image | default "postgres:alpine" }}
  command:
    - sh
    - -c
    - |
      retries=0
      max_retries={{ .retries | default 30 }}
      timeout={{ .timeout | default 6 }}
      while [ "$retries" -lt "$max_retries" ]; do
        retries=$((retries + 1))
        echo "Attempt $retries of $max_retries"
        if pg_isready -h {{ .postgres_host }} -p {{ .postgres_port | default 5432 }}; then
          exit 0
        else
          echo "Failed to connect to Postgres, retrying in $timeout seconds..."
          sleep "$timeout"
        fi
      done
      echo "Failed to connect to Postgres after $max_retries retries, exiting"
      exit 1
{{- end }}
