#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

pgcli "postgres://postgres:${POSTGRES_PASSWORD}@127.0.0.1:5436/postgres"
