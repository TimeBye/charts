{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "hackmd.name" -}}
{{- default "hackmd" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "hackmd.fullname" -}}
{{- $name := default "hackmd" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Helm required labels */}}
{{- define "hackmd.labels" -}}
heritage: {{ .Release.Service }}
release: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app: "{{ include "hackmd.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "hackmd.matchLabels" -}}
release: {{ .Release.Name }}
app: "{{ include "hackmd.name" . }}"
{{- end -}}

{{- define "hackmd.autoGenCert" -}}
  {{- if and .Values.expose.tls.enabled (not .Values.expose.tls.secretName) -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.redis" -}}
  {{- printf "%s-redis" (include "hackmd.fullname" .) -}}
{{- end -}}

{{- define "hackmd.database" -}}
  {{- printf "%s-database" (include "hackmd.fullname" .) -}}
{{- end -}}

{{- define "hackmd.core" -}}
  {{- printf "%s-core" (include "hackmd.fullname" .) -}}
{{- end -}}

{{- define "hackmd.core.serviceName" -}}
  {{- if or (eq .Values.expose.type "clusterIP") (eq .Values.expose.type "ingress") -}}
    {{- default (include "hackmd.core" .) .Values.expose.clusterIP.name -}}
  {{- else if eq .Values.expose.type "nodePort" -}}
    {{- default (include "hackmd.core" .) .Values.expose.nodePort.name -}}
  {{- else if eq .Values.expose.type "loadBalancer" -}}
    {{- default (include "hackmd.core" .) .Values.expose.loadBalancer.name -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.core.backupSchedule" -}}
  {{- if ne .Values.core.env.hackmd_BACKUP_SCHEDULE "disable" -}}
    {{- $split := splitList ":" .Values.core.env.hackmd_BACKUP_TIME }}
    {{- if eq .Values.core.env.hackmd_BACKUP_SCHEDULE "daily" -}}
      {{- printf "%s %s * * *" (index $split 1 ) (index $split 0 ) -}}
    {{- else if eq .Values.core.env.hackmd_BACKUP_SCHEDULE "weekly" -}}
      {{- printf "%s %s * * 0" (index $split 1 ) (index $split 0 ) -}}
    {{- else if eq .Values.core.env.hackmd_BACKUP_SCHEDULE "monthly" -}}
      {{- printf "%s %s 01 * *" (index $split 1 ) (index $split 0 ) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.ingress" -}}
  {{- printf "%s-ingress" (include "hackmd.fullname" .) -}}
{{- end -}}

{{- define "hackmd.database.host" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- include "hackmd.database" . }}
  {{- else -}}
    {{- .Values.database.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.database.port" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "5432" -}}
  {{- else -}}
    {{- .Values.database.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.database.rawUsername" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "hackmd" -}}
  {{- else -}}
    {{- .Values.database.external.username -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.database.encryptedUsername" -}}
  {{- include "hackmd.database.rawUsername" . | b64enc | quote -}}
{{- end -}}

{{- define "hackmd.database.rawPassword" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- .Values.database.internal.password -}}
  {{- else -}}
    {{- .Values.database.external.password -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.database.encryptedPassword" -}}
  {{- include "hackmd.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{- define "hackmd.database.rawDatabaseName" -}}
  {{- if eq .Values.database.type "internal" -}}
    {{- printf "%s" "hackmdhq_production" -}}
  {{- else -}}
    {{- .Values.database.external.databaseName -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.database.encryptedDatabaseName" -}}
  {{- include "hackmd.database.rawDatabaseName" . | b64enc | quote -}}
{{- end -}}

{{- define "hackmd.database.encryptedURL" -}}
  {{- printf "postgres://%s:%s@%s:%s/%s" (include "hackmd.database.rawUsername" .) (include "hackmd.database.rawPassword" .) (include "hackmd.database.host" .) (include "hackmd.database.port" .) (include "hackmd.database.rawDatabaseName" .)| b64enc | quote -}}
{{- end -}}

{{- define "hackmd.redis.host" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- include "hackmd.redis" . -}}
  {{- else -}}
    {{- .Values.redis.external.host -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.redis.port" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- printf "%s" "6379" -}}
  {{- else -}}
    {{- .Values.redis.external.port -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.redis.rawPassword" -}}
  {{- if eq .Values.redis.type "internal" -}}
    {{- if .Values.redis.internal.password }}
      {{- .Values.redis.internal.password -}}
    {{- else -}}
      {{- printf "%s" "" -}}
    {{- end -}}
  {{- else -}}
    {{- if .Values.redis.external.password }}
      {{- .Values.redis.external.password -}}
    {{- else -}}
      {{- printf "%s" "" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "hackmd.redis.encryptedPassword" -}}
  {{- if (include "hackmd.redis.rawPassword" .) }}
    {{- include "hackmd.redis.rawPassword" . | b64enc | quote -}}
  {{- else -}}
    {{- printf "%s" "" -}}
  {{- end -}}
{{- end -}}