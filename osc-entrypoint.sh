#!/bin/bash
set -e

# === FerretDB connection to PostgreSQL + DocumentDB ===
if [ -z "$FERRETDB_POSTGRESQL_URL" ]; then
  if [ -n "$POSTGRES_HOST" ] && [ -n "$POSTGRES_PASSWORD" ]; then
    urlencode() {
      local LC_ALL=C s="$1" out="" c i
      for ((i = 0; i < ${#s}; i++)); do
        c="${s:i:1}"
        case "$c" in
          [a-zA-Z0-9.~_-]) out+="$c" ;;
          *) out+=$(printf '%%%02X' "'$c") ;;
        esac
      done
      printf '%s' "$out"
    }
    PG_USER="${POSTGRES_USER:-postgres}"
    export FERRETDB_POSTGRESQL_URL="postgres://$(urlencode "$PG_USER"):$(urlencode "$POSTGRES_PASSWORD")@${POSTGRES_HOST}:${POSTGRES_PORT:-5432}/postgres"
  else
    echo "ERROR: FERRETDB_POSTGRESQL_URL must be set (e.g. postgres://user:password@host:5432/postgres)." >&2
    echo "       Alternatively set POSTGRES_HOST and POSTGRES_PASSWORD (optionally POSTGRES_PORT, POSTGRES_USER)." >&2
    echo "       The database name must be 'postgres'." >&2
    exit 1
  fi
fi

# === OSC defaults ===
# Mongo wire protocol on 27017; FerretDB debug HTTP server on 8080 serves the platform health probe
# (/debug/livez, /debug/readyz).
export FERRETDB_LISTEN_ADDR="${FERRETDB_LISTEN_ADDR:-:27017}"
export FERRETDB_DEBUG_ADDR="${FERRETDB_DEBUG_ADDR:-:8080}"
export FERRETDB_STATE_DIR="${FERRETDB_STATE_DIR:-/state}"
export FERRETDB_TELEMETRY="${FERRETDB_TELEMETRY:-disable}"
# FERRETDB_AUTH and FERRETDB_LOG_LEVEL are passed through if set

exec /ferretdb "$@"
