set -e

export BIGTABLE_EMULATOR_HOST={{ include "common.fullname" . }}-cbtemulator:{{ .Values.cbtemulator.service.ports.default.port }}

gcloud components update
gcloud components install cbt
cbt -project "flatline-dev" -instance "storage" createtable "contacts" families=c
cbt -project "flatline-dev" -instance "storage" createtable "contact-manifests" families=m
cbt -project "flatline-dev" -instance "storage" createtable "groups" families=g
cbt -project "flatline-dev" -instance "storage" createtable "group-logs" families=l
