{{/*
Expand the name of the chart.
*/}}
{{- define "c3nav.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "c3nav.fullname" -}}
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
{{- define "c3nav.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "c3nav.labels" -}}
helm.sh/chart: {{ include "c3nav.chart" . }}
{{ include "c3nav.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "c3nav.selectorLabels" -}}
app.kubernetes.io/name: {{ include "c3nav.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Name of the secret with the c3nav.cfg
*/}}
{{- define "c3nav.configSecretName" -}}
{{- default (printf "%s-config" .Release.Name) .Values.overrideC3navConfigSecretName -}}
{{- end }}

{{/*
The key containing the c3nav config in the secret
*/}}
{{- define "c3nav.configSecretKey" -}}
{{- default "c3nav.cfg" .Values.overrideC3navConfigSecretKey -}}
{{- end }}


{{/*
Create the default hostname for the ingress
*/}}
{{- define "c3nav.defaultIngressHost" -}}
{{- printf "%s.c3nav.de" .Release.Name -}}
{{- end }}

{{/*
Create the name of the traefik basic auth middleware
*/}}
{{- define "c3nav.traeficBasicAuthMiddlewareName" -}}
{{- if and (eq .Values.ingress.className "traefik") (or .Values.ingress.basicAuth .Values.ingress.existingBasicAuthSecret) -}}
{{- default (printf "%s-basic-auth" (include "c3nav.fullname" .)) .Values.ingress.basicAuthMiddlewareNameOverride }}
{{- end }}
{{- end }}

{{/*
Create the name of the traefik basic auth secret
*/}}
{{- define "c3nav.traeficBasicAuthSecretName" -}}
{{- if and (eq .Values.ingress.className "traefik") (or .Values.ingress.basicAuth .Values.ingress.existingBasicAuthSecret) -}}
{{- if .Values.ingress.existingBasicAuthSecret }}
{{ .Values.ingress.existingBasicAuthSecret }}
{{- else }}
{{- default (printf "%s-basic-auth" (include "c3nav.fullname" .)) .Values.ingress.basicAuthSecretNameOverride }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "c3nav.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "c3nav.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Convert a key / value pair to a config line for the c3nav.cfg ini file 
*/}}
{{- define "c3nav.toIniLine" -}}
{{- if kindIs "slice" .value }}
{{- .key }}={{ range .value }}{{ . }},{{ end }}
{{- else }}
{{- .key }}={{ .value }}
{{- end }}
{{- end }}
