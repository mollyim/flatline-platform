set -e

export BIGTABLE_EMULATOR_HOST={{ include "common.fullname" . }}-cbtemulator:{{ .Values.cbtemulator.service.ports.default.port }}

PROJECT="flatline-dev"
INSTANCE="storage"
TABLE_FAMILY="contacts:c contact-manifests:m groups:g group-logs:l"

echo "Using '$BIGTABLE_EMULATOR_HOST' as Bigtable emulator host."
echo "Using project '$PROJECT', instance '$INSTANCE'."
echo "Creating the following tables and column families:"
echo $TABLE_FAMILY

echo "Listing existing tables..."
tables=$(cbt -project "$PROJECT" -instance "$INSTANCE" ls || true)

exists() {
  table=$1
  printf '%s\n' "$tables" | grep -x "$table" >/dev/null 2>&1
}

echo "Creating missing tables...";
for pair in $TABLE_FAMILY; do
  table=${pair%%:*}
  family=${pair##*:}
  if exists "$table"; then
    echo "Table '$table' exists. Skipped."
  else
    echo "Creating table '$table' with family '$family'..."
    cbt -project "$PROJECT" -instance "$INSTANCE" createtable "$table" families="$family"
  fi
done

echo "Finished creating tables."
