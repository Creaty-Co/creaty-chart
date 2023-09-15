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
