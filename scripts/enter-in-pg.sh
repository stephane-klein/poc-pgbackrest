#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

pgcli --less-chatty "postgres://postgres:password@127.0.0.1:5432/postgres"
