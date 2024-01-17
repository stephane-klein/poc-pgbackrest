#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

export PGPASSWORD=${POSTGRES_PASSWORD}
psql -n -q -d postgres -h 127.0.0.1 -p 5435 -U postgres -f ../sqls/seed.sql
