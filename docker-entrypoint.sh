#!/usr/bin/env bash

set -e

/usr/local/bin/docker-entrypoint.sh postgres -c 'config_file=/etc/postgresql/postgresql.conf' &

until pg_isready -t 60 -U $POSTGRES_USER -h $(hostname -i) &>/dev/null
do
  echo "Waiting for PostgreSQL..."
  sleep 1
done

gomplate -f /etc/pgbackrest.conf.tmpl -o /etc/pgbackrest.conf

if [[ -v PGBACKREST_STANZA_CREATE ]]; then
    su postgres -c "pg_ctl status"
    su postgres -p -c 'pgbackrest --stanza=instance1 --log-level-console=info stanza-create'
    su postgres -p -c 'pgbackrest --stanza=instance1 --log-level-console=info check'
    su postgres -p -c 'pgbackrest --stanza=instance1 --log-level-console=info backup'
fi

if [[ -v START_SUPERCRONIC ]]; then
    /usr/local/bin/supercronic /crontab &
fi

wait -n
