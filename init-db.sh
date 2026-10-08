#!/bin/bash
set -e

HOST="${POSTGRES_HOST:-shared-postgres-db}"
SUPERUSER="${POSTGRES_USER:-postgres}"
PASS="${EVOLUTION_DB_PASS:-evolution_pass}"

until PGPASSWORD="$POSTGRES_PASSWORD" pg_isready -h "$HOST" -U "$SUPERUSER" -q; do
  echo "Waiting for postgres..."
  sleep 2
done

PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$HOST" -U "$SUPERUSER" -d postgres <<-EOSQL
	DO \$\$ BEGIN
	  CREATE USER evolution WITH ENCRYPTED PASSWORD '$PASS';
	EXCEPTION WHEN duplicate_object THEN NULL;
	END \$\$;

	SELECT 'CREATE DATABASE evolution OWNER evolution'
	WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'evolution')\gexec

	GRANT ALL PRIVILEGES ON DATABASE evolution TO evolution;
EOSQL

PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$HOST" -U "$SUPERUSER" -d evolution \
  -c "GRANT ALL ON SCHEMA public TO evolution;"

echo "evolution database ready."
