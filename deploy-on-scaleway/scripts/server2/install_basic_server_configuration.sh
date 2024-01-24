#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../../"

SERVER2_IP=$(terraform show --json | jq '.values.root_module.resources[] | select(.address=="scaleway_instance_server.server2") | .values.public_ip' -r)

ssh root@$SERVER2_IP 'bash -s' < server2/_install_basic_server_configuration.sh
