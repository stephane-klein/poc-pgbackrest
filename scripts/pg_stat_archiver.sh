#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

export PGPASSWORD=password
psql -n -q -d postgres -h localhost -p 5432 -U postgres -c "select * from pg_catalog.pg_stat_archiver;"
