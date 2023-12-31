#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec postgres2 sh -c "su postgres -p -c 'pgbackrest --stanza=instance1 $@'"
