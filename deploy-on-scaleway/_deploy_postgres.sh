#!/usr/bin/env bash
set -e

PROJECT_FOLDER="/srv/postgres/"

mkdir -p ${PROJECT_FOLDER}

cat <<EOF > ${PROJECT_FOLDER}docker-compose.yaml
version: '3.8'
services:
  postgres:
    image: postgres_with_pgbackrest:latest
    restart: unless-stopped
    ports:
      - 127.0.0.1:5432:5432
    environment:
      POSTGRES_DB: postgres
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: {{ .Env.POSTGRES_PASSWORD }}
      START_SUPERCRONIC: 1
      PGBACKREST_REPO1_PATH: "/repo"
      PGBACKREST_REPO1_S3_URI_STYLE: "host"
      PGBACKREST_REPO1_S3_ENDPOINT: s3.fr-par.scw.cloud
      PGBACKREST_REPO1_S3_BUCKET: pgbackrest-backup-bucket2
      PGBACKREST_REPO1_S3_VERIFY_TLS: y
      PGBACKREST_REPO1_S3_KEY: {{ .Env.SCW_ACCESS_KEY }}
      PGBACKREST_REPO1_S3_KEY_SECRET: {{ .Env.SCW_SECRET_KEY }}
      PGBACKREST_REPO1_S3_REGION: fr-par
      PGBACKREST_REPO1_RETENTION_FULL: 2
    volumes:
      - /var/lib/postgres/:/var/lib/postgresql/data
    healthcheck:
      test: pg_isready -U postgres
      interval: 10s
      start_period: 30s

EOF

cd ${PROJECT_FOLDER}

docker compose up -d postgres --wait
