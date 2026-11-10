#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 -U postgres <<SQL
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replpass';
SQL
echo "host replication replicator all md5" >> "$PGDATA/pg_hba.conf"
