#!/usr/bin/env bash
set -euo pipefail
# El rol de l'API només llig; no reutilitzem el compte administrador del contenidor.
psql --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
  --set=ON_ERROR_STOP=1 --set=api_password="$HEALTHYS_API_PASSWORD" <<'SQL'
CREATE ROLE healthys_api LOGIN PASSWORD :'api_password';
GRANT CONNECT ON DATABASE healthys TO healthys_api;
GRANT USAGE ON SCHEMA healthys TO healthys_api;
GRANT SELECT ON ALL TABLES IN SCHEMA healthys TO healthys_api;
ALTER DEFAULT PRIVILEGES IN SCHEMA healthys GRANT SELECT ON TABLES TO healthys_api;
SQL
