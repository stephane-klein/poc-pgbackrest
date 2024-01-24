#!/usr/bin/env bash

set -e

chown postgres /var/lib/postgresql/data/
chmod go-rwX /var/lib/postgresql/data/
gomplate -f /etc/pgbackrest.conf.tmpl -o /etc/pgbackrest.conf

su postgres -p -c "pgbackrest --stanza=instance1 --log-level-console=info restore --type=time --target-action=shutdown --target='$1'"
/usr/local/bin/docker-entrypoint.sh postgres
rm -f $PGDATA/recovery.signal
rm -f $PGDATA/postgresql.auto.conf
