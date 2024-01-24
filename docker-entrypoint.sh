#!/usr/bin/env bash

set -e

gomplate -f /etc/pgbackrest.conf.tmpl -o /etc/pgbackrest.conf

cat <<EOF > /pgbackrest.sh
#!/usr/bin/env sh

if test -f /stanza_instance1_exists; then
    pgbackrest --stanza=instance1 archive-push \$1
fi
EOF
chmod ugo+rx /pgbackrest.sh

if [[ -v ENABLE_PGBACKREST_BACKUP ]]; then
    cp /usr/share/postgresql/postgresql.conf.sample /etc/postgresql/postgresql.conf

    sed -i -r "s/^#?(archive_mode) .*$/\1 = on/" /etc/postgresql/postgresql.conf
    sed -i -r "s/^#?(archive_command) .*$/archive_command = '\/pgbackrest.sh %p'/" /etc/postgresql/postgresql.conf
    sed -i -r "s/^#?(archive_timeout) .*$/\1 = 60/" /etc/postgresql/postgresql.conf
fi

/usr/local/bin/docker-entrypoint.sh postgres -c 'config_file=/etc/postgresql/postgresql.conf' &

until pg_isready -t 60 -U $POSTGRES_USER -h $(hostname -i) &>/dev/null
do
  echo "Waiting for PostgreSQL..."
  sleep 1
done

if [[ -v ENABLE_PGBACKREST_BACKUP ]]; then
    if ! pgbackrest --stanza=instance1 info | grep "status: ok";then
        # initialize pgbackrest stanza only if it not exists
        su postgres -c "pg_ctl status"

        echo "Start pgbackrest stanza-create ..."
        su postgres -p -c 'pgbackrest --stanza=instance1 --log-level-console=info stanza-create'
        echo "... pgbackrest stanza-create done"

        # This file `/stanza_instance1_exists` enables Postgres to execute archive_command (pgbackrest archive-push).
        # This mechanism avoids launching "pgbackrest archive-push" when the stanza has not yet been created.
        # It's important to create this file here, just before pgbackrest check.
        touch /stanza_instance1_exists

        echo "Start pgbackrest check ..."
        su postgres -p -c 'pgbackrest --stanza=instance1 --log-level-console=info check'
        echo "... pgbackrest check done"

        echo "Start pgbackrest back ..."
        su postgres -p -c 'pgbackrest --stanza=instance1 --log-level-console=info backup'
        echo "... pgbackrest backup done"
    fi
    if pgbackrest --stanza=instance1 info | grep "status: ok";then
        if [[ ! -v DISABLE_SUPERCRONIC ]]; then
            /usr/local/bin/supercronic /crontab &
            echo "Supercronic started"
        else
            echo "Supercronic disabled"
        fi
    else
        echo "pgbackrest status not ok, then supercronic not started"
    fi
fi

sleep 10h

wait -n
