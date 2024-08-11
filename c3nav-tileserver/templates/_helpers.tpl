{{/*
Expand the name of the chart.
*/}}
{{- define "c3nav-tileserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "c3nav-tileserver.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "c3nav-tileserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "c3nav-tileserver.labels" -}}
helm.sh/chart: {{ include "c3nav-tileserver.chart" . }}
{{ include "c3nav-tileserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "c3nav-tileserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "c3nav-tileserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "c3nav-tileserver.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "c3nav-tileserver.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the secret
*/}}
{{- define "c3nav-tileserver.secretName" -}}
{{- if .Values.existingSecret }}
{{- .Values.existingSecret -}}
{{- else }}
{{- .Values.overrideSecretName | default (include "c3nav-tileserver.fullname" .) -}}
{{- end }}
{{- end }}

{{/*
The key containing the tile secret
*/}}
{{- define "c3nav-tileserver.tileSecretKey" -}}
{{- .Values.tileSecretKey | default "tile_secret" -}}
{{- end }}

{{/*
The key containing the http auth secret
*/}}
{{- define "c3nav-tileserver.httpAuthKey" -}}
{{- .Values.httpAuthKey | default "http_auth" -}}
{{- end }}

{{/*
Create the default hostname for the ingress
*/}}
{{- define "c3nav-tileserver.defaultDomain" -}}
{{- printf "tiles.%s.c3nav.de" (.Values.c3nav.name | default .Release.Name) -}}
{{- end }}

{{/*
The domains/hostname this instance is for
*/}}
{{- define "c3nav-tileserver.domains" -}}
{{- if not (empty .Values.tileserverDomains )}}
{{- join "," .Values.tileserverDomains }}
{{- else }}
{{- include "c3nav-tileserver.defaultDomain" . }}
{{- end }}
{{- end }}

{{/*
Create the name of the traefik basic auth middleware
*/}}
{{- define "c3nav-tileserver.traeficBasicAuthMiddlewareName" -}}
{{- if and (eq .Values.ingress.className "traefik") (or .Values.ingress.basicAuth .Values.ingress.existingBasicAuthSecret) -}}
{{- .Values.ingress.basicAuthMiddlewareNameOverride | default (printf "%s-basic-auth" (include "c3nav-tileserver.fullname" .)) }}
{{- end }}
{{- end }}

{{/*
Create the name of the traefik basic auth secret
*/}}
{{- define "c3nav-tileserver.basicAuthSecretName" -}}
{{- if and (eq .Values.ingress.className "traefik") (or .Values.ingress.basicAuth .Values.ingress.existingBasicAuthSecret) -}}
{{- if .Values.ingress.existingBasicAuthSecret }}
{{ .Values.ingress.existingBasicAuthSecret }}
{{- else }}
{{- .Values.ingress.basicAuthSecretNameOverride | default (printf "%s-basic-auth" (include "c3nav-tileserver.fullname" .)) }}
{{- end }}
{{- end }}
{{- end }}
