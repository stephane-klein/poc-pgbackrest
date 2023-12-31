#!/usr/bin/env bash

set -e

gomplate -f /etc/pgbackrest.conf.tmpl -o /etc/pgbackrest.conf

su postgres -p -c 'pgbackrest --stanza=instance1 --log-level-console=info restore'
