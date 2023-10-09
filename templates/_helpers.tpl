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

{{- define "cal_domain" }}
    {{- if .Values.cal_domain }}
        {{- .Values.cal_domain }}
    {{- else }}
        {{- printf "%s-cal.creaty.club" .Release.Name }}
    {{- end }}
{{- end }}

{{- define "configmap" }}
{{- range $name, $config := ._configs }}
  {{ $name }}: |
    {{- (tpl $config.value $._) | trim | nindent 4 }}
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
{{- range $name, $value := ._envs }}
  {{- if and (kindIs "map" $value) (hasKey $value "secret") }}
- name: {{ $name }}
  valueFrom:
    secretKeyRef:
      name: {{ $value.secret }}
      key: {{ default $name $value.key }}
  {{- end }}
{{- end }}
{{- range $name, $value := ._envs }}
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
      max_retries={{ .retries | default 10 }}
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
      max_retries={{ .retries | default 15 }}
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
