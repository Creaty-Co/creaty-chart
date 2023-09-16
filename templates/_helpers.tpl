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

{{- define "email_envs" }}
env:
  - name: EMAIL_SERVER_HOST
    valueFrom:
      configMapKeyRef:
        name: email-config
        key: EMAIL_SERVER_HOST
  - name: EMAIL_SERVER_PORT
    valueFrom:
      configMapKeyRef:
        name: email-config
        key: EMAIL_SERVER_PORT
  - name: EMAIL_SERVER_USER
    valueFrom:
      configMapKeyRef:
        name: email-config
        key: EMAIL_SERVER_USER
  - name: EMAIL_SERVER_PASSWORD
    valueFrom:
      secretKeyRef:
        name: aboba
        key: EMAIL_SERVER_PASSWORD
  - name: EMAIL_URL
    value: >
      smtp+ssl://${EMAIL_SERVER_USER}:${EMAIL_SERVER_PASSWORD}
      @${EMAIL_SERVER_HOST}:${EMAIL_SERVER_PORT}
{{- end }}
