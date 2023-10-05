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
- name: {{ $name }}
  {{- if not (and (kindIs "map" $value) (hasKey $value "secret")) }}
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
