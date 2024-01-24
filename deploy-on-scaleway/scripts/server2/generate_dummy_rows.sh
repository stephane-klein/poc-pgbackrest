#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

export PGPASSWORD=${POSTGRES_PASSWORD}
psql -n -q -d postgres -h 127.0.0.1 -p 5436 -U postgres -c "select insert_dummy_records(10); select * from dummy order by id desc limit 1"
