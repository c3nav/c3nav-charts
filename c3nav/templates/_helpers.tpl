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
container images
*/}}
{{- define "c3nav.images.core" -}}
{{ printf "%s/%s:%s" .Values.image.registry .Values.image.coreRepository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}
{{- define "c3nav.images.core_metrics" -}}
{{ printf "%s/%s:%s" .Values.core.metrics.image.registry .Values.core.metrics.image.repository .Values.core.metrics.image.tag }}
{{- end }}
{{- define "c3nav.images.tiles" -}}
{{ printf "%s/%s:%s" .Values.image.registry (default .Values.image.coreRepository .Values.image.tilesRepository) (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}
{{- define "c3nav.images.worker" -}}
{{ printf "%s/%s:%s" .Values.image.registry .Values.image.coreRepository (default .Chart.AppVersion .Values.image.tag) }}
{{- end }}
{{- define "c3nav.images.static" -}}
{{ printf "%s/%s:%s" .Values.static.image.registry .Values.static.image.repository .Values.static.image.tag }}
{{- end }}


{{/*
Name of the ConfigMap with the c3nav.cfg
*/}}
{{- define "c3nav.configMapName" -}}
{{- if .Values.existingC3navConfigMap }}
{{- .Values.existingC3navConfigMap -}}
{{- else }}
{{- .Values.overrideC3navConfigMapName | default (printf "%s-config" (include "c3nav.fullname" .)) -}}
{{- end }}
{{- end }}

{{/*
The key containing the c3nav config file in the secret
*/}}
{{- define "c3nav.configKey" -}}
{{- .Values.c3navConfigKey | default "c3nav.cfg" -}}
{{- end }}

{{/*
The key containing the c3nav config file in the secret
*/}}
{{- define "c3nav.configPath" -}}
{{- .Values.overrideC3navConfigPath | default "/etc/c3nav/c3nav.cfg" -}}
{{- end }}


{{/*
Name of the main secret
*/}}
{{- define "c3nav.secretName" -}}
{{- if .Values.existingC3navSecret }}
{{- .Values.existingC3navSecret -}}
{{- else }}
{{- .Values.overrideC3navSecretName | default (printf "%s-secret" (include "c3nav.fullname" .)) -}}
{{- end }}
{{- end }}

{{/*
The key containing the django secret
*/}}
{{- define "c3nav.djangoSecretKey" -}}
{{- .Values.djangoSecretKey | default "django_secret" -}}
{{- end }}

{{/*
The django secret
*/}}
{{- define "c3nav.djangoSecret" -}}
{{- if .Values.c3nav.django.secret }}
{{- .Values.c3nav.django.secret }}
{{- else }}
{{- /* retrieve the secret data using lookup function and when not exists, return an empty dictionary / map as result */}}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "c3nav.secretName" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- /* use to existing secret data or generate a random one when it doesn't exists */}}
{{- get $secretData (include "c3nav.djangoSecretKey" . ) | b64dec | default (randAlphaNum 50) -}}
{{- end }}
{{- end }}

{{/*
The key containing the mesh secret
*/}}
{{- define "c3nav.meshSecretKey" -}}
{{- .Values.meshSecretKey | default "mesh_secret" -}}
{{- end }}

{{/*
The mesh secret
*/}}
{{- define "c3nav.meshSecret" -}}
{{- if .Values.c3nav.mesh_secret }}
{{- .Values.c3nav.mesh_secret }}
{{- else }}
{{- /* retrieve the secret data using lookup function and when not exists, return an empty dictionary / map as result */}}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "c3nav.secretName" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- /* use to existing secret data or generate a random one when it doesn't exists */}}
{{- get $secretData (include "c3nav.meshSecretKey" . ) | b64dec | default (randAlphaNum 32) -}}
{{- end }}
{{- end }}

{{/*
The key containing the tile secret
*/}}
{{- define "c3nav.tileSecretKey" -}}
{{- .Values.tileSecretKey | default "tile_secret" -}}
{{- end }}

{{/*
The tile secret
*/}}
{{- define "c3nav.tileSecret" -}}
{{- if .Values.c3nav.tile_secret }}
{{- .Values.c3nav.tile_secret }}
{{- else }}
{{- /* retrieve the secret data using lookup function and when not exists, return an empty dictionary / map as result */}}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "c3nav.secretName" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- /* use to existing secret data or generate a random one when it doesn't exists */}}
{{- get $secretData (include "c3nav.tileSecretKey" . ) | b64dec | default (randAlphaNum 50) -}}
{{- end }}
{{- end }}


{{/*
The name of the database secret
*/}}
{{- define "c3nav.databaseSecretName" -}}
{{- if .Values.existingDatabaseSecret }}
{{- .Values.existingDatabaseSecret -}}
{{- else if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.existingSecret | default (include "c3nav.subchart.fullname" (dict "chart" "postgresql" "Values" .Values.postgresql "Release" .Release)) }}
{{- else }}
{{- .Values.overrideDatabaseSecretName | default (include "c3nav.secretName" .) -}}
{{- end }}
{{- end }}

{{/*
The key containing the database password
*/}}
{{- define "c3nav.databasePasswordKey" -}}
{{- if or .Values.existingDatabaseSecret (not .Values.postgresql.enabled) }}
{{- .Values.databasePasswordKey | default "database_password" }}
{{- else }}
{{- (default dict .Values.postgresql.auth.secretKeys).userPasswordKey | default "password" }}
{{- end }}
{{- end }}

{{/*
The database name
*/}}
{{- define "c3nav.databaseName" -}}
{{- .Values.c3nav.database.name | default (printf "c3nav-%s" .Release.Name) -}}
{{- end }}

{{/*
The database user
*/}}
{{- define "c3nav.databaseUser" -}}
{{- if and (empty .Values.c3nav.database.user) .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- .Values.c3nav.database.user | default (printf "c3nav-%s" .Release.Name) -}}
{{- end }}
{{- end }}

{{/*
The database host
*/}}
{{- define "c3nav.databaseHost" -}}
{{- if and (empty .Values.c3nav.database.host) .Values.postgresql.enabled }}
{{- printf "%s.%s.svc.%s" (include "c3nav.subchart.fullname" (dict "chart" "postgresql" "Values" .Values.postgresql "Release" .Release)) .Release.Namespace .Values.clusterDomain }}
{{- if eq .Values.postgresql.architecture "replication"}}
{{- printf "-%s" ((default dict .Values.postgresql.primary).name | default "primary") }}
{{- end }}
{{- else }}
{{- .Values.c3nav.database.host -}}
{{- end }}
{{- end }}

{{/*
The database port
*/}}
{{- define "c3nav.databasePort" -}}
{{- if and (empty .Values.c3nav.database.port) .Values.postgresql.enabled }}
{{- (default dict (default dict (default dict .Values.postgresql.primary).service).ports).postgresql | default "5432" }}
{{- else if and (empty .Values.c3nav.database.port) (eq .Values.c3nav.database.backend "postgresql") }}
{{- print "5432" }}
{{- else }}
{{- .Values.c3nav.database.port -}}
{{- end }}
{{- end }}


{{/*
The name of memcached secret with the password for memcached
*/}}
{{- define "c3nav.memcachedSecretName" -}}
{{- .Values.existingMemcachedSecret | default (printf "%s-%s" .Release.Name "memcached") -}}
{{- end }}

{{/*
The key containing the memcached connection URL
*/}}
{{- define "c3nav.memcachedKey" -}}
{{- .Values.memcachedKey | default "memcached" -}}
{{- end }}

{{/*
The memcached username
*/}}
{{- define "c3nav.memcachedUser" -}}
{{- if (and .Values.memcached.enabled .Values.memcached.auth.enabled) }}
{{- .Values.memcached.auth.username }}
{{- else }}
{{- .Values.c3nav.memcached.username }}
{{- end }}
{{- end }}

{{/*
The memcached password
*/}}
{{- define "c3nav.memcachedPassword" -}}
{{- if .Values.c3nav.memcached.password }}
{{- .Values.c3nav.memcached.password }}
{{- else }}
{{- if (and .Values.memcached.enabled .Values.memcached.auth.enabled) }}
{{- if .Values.memcached.auth.password }}
{{- .Values.memcached.auth.password }}
{{- else }}
{{- /* retrieve the secret data using lookup function and when not exists, return an empty dictionary / map as result */}}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "c3nav.memcachedSecretName" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- /* use to existing secret data or generate a random one when it doesn't exists */}}
{{- get $secretData "memcached-password" | b64dec | default (randAlphaNum 16) -}}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
The memcached connection URL for django's caching framework
*/}}
{{- define "c3nav.memcachedConnection" -}}
{{- if (and .Values.memcached.enabled (empty .Values.c3nav.memcached.location)) -}}
{{- printf "%s.%s.svc.%s:%v" (include "c3nav.subchart.fullname" (dict "chart" "memcached" "Values" .Values.memcached "Release" .Release)) .Release.Namespace .Values.clusterDomain (.Values.memcached.service.ports.memcache | default "11211") -}}
{{- else}}
{{- .Values.c3nav.memcached.location -}}
{{- end }}
{{- end }}


{{/*
The key containing the redis connection URL
*/}}
{{- define "c3nav.redisPasswordKey" -}}
{{- .Values.redisPasswordKey | default "redis-password" -}}
{{- end }}

{{/*
The redis password
*/}}
{{- define "c3nav.redisPassword" -}}
{{- if .Values.c3nav.redis.password }}
{{- .Values.c3nav.redis.password }}
{{- else }}
{{- if (and .Values.redis.enabled .Values.redis.auth.enabled) }}
{{- if .Values.redis.auth.password }}
{{- .Values.redis.auth.password }}
{{- else }}
{{- /* retrieve the secret data using lookup function and when not exists, return an empty dictionary / map as result */}}
{{- $secretObj := (lookup "v1" "Secret" .Release.Namespace (include "c3nav.secretName" . )) | default dict }}
{{- $secretData := (get $secretObj "data") | default dict }}
{{- /* use to existing secret data or generate a random one when it doesn't exists */}}
{{- $password := get $secretData (include "c3nav.redisPasswordKey" . ) | b64dec | default (randAlphaNum 16) -}}
{{- $_ := set .Values.redis.auth "password" $password -}}
{{- $password -}}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
The key containing the redis connection URL
*/}}
{{- define "c3nav.redisKey" -}}
{{- .Values.redisKey | default "redis" -}}
{{- end }}

{{/*
The base redis URL without a database
*/}}
{{- define "c3nav.redisBaseURL" -}}
{{- printf "redis://:%s@%s-master.%s.svc.%s:%v" ( include "c3nav.redisPassword" . ) (include "c3nav.subchart.fullname" (dict "chart" "redis" "Values" .Values.redis "Release" .Release)) .Release.Namespace .Values.clusterDomain (.Values.redis.master.service.ports.redis | default 6379) -}}
{{- end }}

{{/*
The redis connection URL for django's caching framework
*/}}
{{- define "c3nav.redisConnection" -}}
{{- if (and .Values.redis.enabled (empty .Values.c3nav.redis.location)) -}}
{{- printf "%s/0" (include "c3nav.redisBaseURL" . ) }}
{{- else }}
{{- .Values.c3nav.redis.location -}}
{{- end }}
{{- end }}


{{/*
The key containing the celery broker URL
*/}}
{{- define "c3nav.celeryBrokerKey" -}}
{{- .Values.celeryBrokerKey | default "celery_broker" -}}
{{- end }}

{{/*
The celery broker URL
*/}}
{{- define "c3nav.celeryBroker" -}}
{{- if (and .Values.redis.enabled (empty .Values.c3nav.celery.broker)) -}}
{{- printf "%s/2" (include "c3nav.redisBaseURL" . ) }}
{{- else }}
{{- .Values.c3nav.celery.broker -}}
{{- end }}
{{- end }}

{{/*
The key containing the celery backend URL
*/}}
{{- define "c3nav.celeryBackendKey" -}}
{{- .Values.celeryBackendKey | default "celery_backend" -}}
{{- end }}

{{/*
The celery results backend URL
*/}}
{{- define "c3nav.celeryBackend" -}}
{{- if (and .Values.redis.enabled (empty .Values.c3nav.celery.backend)) -}}
{{- printf "%s/1" (include "c3nav.redisBaseURL" . ) }}
{{- else }}
{{- .Values.c3nav.celery.backend -}}
{{- end }}
{{- end }}


{{/*
The key containing the email (SMTP) username
*/}}
{{- define "c3nav.emailUserKey" -}}
{{- .Values.emailUserKey | default "email_user" -}}
{{- end }}

{{/*
The key containing the email (SMTP) password
*/}}
{{- define "c3nav.emailPasswordKey" -}}
{{- .Values.emailPasswordKey | default "email_password" -}}
{{- end }}


{{/*
Create the default hostname for the ingress
*/}}
{{- define "c3nav.defaultDomain" -}}
{{- printf "%s.c3nav.de" (.Values.c3nav.name | default .Release.Name) -}}
{{- end }}

{{/*
The domains/hostname this instance is for
*/}}
{{- define "c3nav.domains" -}}
{{- if not (empty .Values.domains )}}
{{ join "," .Values.domains }}
{{- else }}
{{- include "c3nav.defaultDomain" . }}
{{- end }}
{{- end }}

{{/*
The django allowed hosts based on the domains or c3nav.django.allowed_hosts setting
*/}}
{{- define "c3nav.allowedHosts" -}}
{{- if not (empty .Values.c3nav.django.allowed_hosts )}}
{{- join "," .Values.c3nav.django.allowed_hosts }}
{{- else }}
{{- include "c3nav.domains" . }}
{{- end }}
{{- end }}

{{/*
The django allowed hosts added at runtime with the help of other environment variables
*/}}
{{- define "c3nav.allowedHostsRuntime" -}}
$(K8S_SERVICE_NAME).$(K8S_POD_NAMESPACE),$(K8S_SERVICE_NAME).$(K8S_POD_NAMESPACE).svc.cluster.local,localhost,$(K8S_POD_IP),127.0.0.1,::1
{{- end }}

{{/*
The name of the PVC for the core pod
*/}}
{{- define "c3nav.core.pvcName" -}}
{{- if .Values.core.persistence.existingClaim }}
{{- .Values.core.persistence.existingClaim }}
{{- else }}
{{- .Values.core.persistence.nameOverride | default ( printf "%s-data" (include "c3nav.fullname" .)) }}
{{- end }}
{{- end }}

{{/*
Create the name of the traefik basic auth middleware
*/}}
{{- define "c3nav.traeficBasicAuthMiddlewareName" -}}
{{- if and (eq .Values.ingress.className "traefik") (or .Values.ingress.basicAuth .Values.ingress.existingBasicAuthSecret) -}}
{{- .Values.ingress.basicAuthMiddlewareNameOverride | default (printf "%s-basic-auth" (include "c3nav.fullname" .)) }}
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
{{- .Values.ingress.basicAuthSecretNameOverride | default (printf "%s-basic-auth" (include "c3nav.fullname" .)) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "c3nav.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- .Values.serviceAccount.name | default (include "c3nav.fullname" .) }}
{{- else }}
{{- .Values.serviceAccount.name | default "default" }}
{{- end }}
{{- end }}

{{/*
The environment variables shared by all c3nav containers, except of the static container
*/}}
{{- define "c3nav.commonEnvVars" -}}
- name: K8S_POD_NAME
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: metadata.name
- name: K8S_POD_NAMESPACE
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: metadata.namespace
- name: K8S_POD_IP
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: status.podIP
- name: C3NAV_DEBUG
  value: {{ .Values.c3nav.debug | quote }}
- name: C3NAV_LOGLEVEL
  value: {{ .Values.c3nav.loglevel | quote }}
- name: C3NAV_CONFIG
  value: {{ include "c3nav.configPath" . | quote }}
- name: C3NAV_DATA_DIR
  value: {{ .Values.core.persistence.mountPath | quote }}
- name: C3NAV_CACHE_ROOT
  value: "/cache"
- name: C3NAV_AUTOMIGRATE
  value: "no"
- name: C3NAV_DJANGO_SECRET_FILE
  value: "/etc/c3nav/django_secret"
- name: C3NAV_TILE_SECRET_FILE
  value: "/etc/c3nav/tile_secret"
- name: C3NAV_MESH_SECRET_FILE
  value: "/etc/c3nav/mesh_secret"
- name: C3NAV_DJANGO_ALLOWED_HOSTS
  value: {{ printf "%s,%s" (include "c3nav.allowedHosts" . ) (include "c3nav.allowedHostsRuntime" . ) | quote }}
- name: C3NAV_MEMCACHED
  valueFrom:
    secretKeyRef:
      name: {{ include "c3nav.secretName" . }}
      key: {{ include "c3nav.memcachedKey" . }}
- name: C3NAV_REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "c3nav.secretName" . }}
      key: {{ include "c3nav.redisPasswordKey" . }}
- name: C3NAV_REDIS
  valueFrom:
    secretKeyRef:
      name: {{ include "c3nav.secretName" . }}
      key: {{ include "c3nav.redisKey" . }}
- name: C3NAV_CELERY_BROKER
  valueFrom:
    secretKeyRef:
      name: {{ include "c3nav.secretName" . }}
      key: {{ include "c3nav.celeryBrokerKey" . }}
- name: C3NAV_CELERY_BACKEND
  valueFrom:
    secretKeyRef:
      name: {{ include "c3nav.secretName" . }}
      key: {{ include "c3nav.celeryBackendKey" . }}
- name: C3NAV_DATABASE_BACKEND
  value: {{ include "c3nav.configValue" .Values.c3nav.database.backend | quote }}
- name: C3NAV_DATABASE_NAME
  value: {{ include "c3nav.databaseName" . | quote }}
- name: C3NAV_DATABASE_USER
  value: {{ include "c3nav.databaseUser" . | quote }}
- name: C3NAV_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "c3nav.databaseSecretName" . | quote }}
      key: {{ include "c3nav.databasePasswordKey" . | quote }}
- name: C3NAV_DATABASE_HOST
  value: {{ include "c3nav.databaseHost" . | quote }}
- name: C3NAV_DATABASE_PORT
  value: {{ include "c3nav.databasePort" . | quote }}
{{- range $key, $value := omit .Values.c3nav.email "user" "password" "url" }}
{{- if $value }}
- name: C3NAV_EMAIL_{{ upper $key }}
  value: {{ include "c3nav.configValue" $value | quote }}
{{- end }}
{{- end }}
- name: C3NAV_EMAIL_USER
  valueFrom:
    secretKeyRef:
      name: {{ include "c3nav.secretName" . }}
      key: {{ .Values.emailUserKey }}
      optional: true
- name: C3NAV_EMAIL_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "c3nav.secretName" . }}
      key: {{ .Values.emailPasswordKey }}
      optional: true
{{- end -}}

{{/*
Convert a config value to a string, correctly serializing lists
*/}}
{{- define "c3nav.configValue" -}}
{{- if kindIs "slice" . }}
{{- range . }}{{ . }},{{ end }}
{{- else }}
{{- . }}
{{- end }}
{{- end }}

{{/*
Convert a key / value pair to a config line for the c3nav.cfg ini file 
*/}}
{{- define "c3nav.toIniLine" -}}
{{- if kindIs "slice" .value }}
{{- .key }}={{ range .value }}{{ . }},{{ end }}
{{- else }}
{{- .key }}={{ tpl .value $.root }}
{{- end }}
{{- end }}


{{/*
Create a default fully qualified name the same way "common.names.fullname" does but for sub-charts
*/}}
{{- define "c3nav.subchart.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .chart .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
