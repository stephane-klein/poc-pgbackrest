#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

SERVER1_IP=$(terraform show --json | jq '.values.root_module.resources[] | select(.address=="scaleway_instance_server.server1") | .values.public_ip' -r)

if [[ -z "${NO_DOCKER_BUILD}" ]]; then
    docker build ../ -t postgres_with_pgbackrest:latest
fi

if [[ -z "${NO_UPLOAD}" ]]; then
    docker save postgres_with_pgbackrest:latest | pv | ssh root@${SERVER1_IP} 'docker load'
fi

gomplate -f _deploy_postgres.sh | ssh root@${SERVER1_IP} 'bash -s'
