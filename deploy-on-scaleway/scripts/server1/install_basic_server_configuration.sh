#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

SERVER1_IP=$(terraform show --json | jq '.values.root_module.resources[] | select(.address=="scaleway_instance_server.server1") | .values.public_ip' -r)

ssh root@$SERVER1_IP 'bash -s' < server1/_install_basic_server_configuration.sh
