# POC pgBackRest

Repository starting point issue (in French): https://github.com/stephane-klein/backlog/issues/322

## Prerequisites

- [rtx](https://github.com/jdx/rtx)
- [Docker Engine](https://docs.docker.com/engine/) (tested with `24.0.6`)
- [pgcli](https://www.pgcli.com/)
- `psql` (More info about `psql` [brew package](https://stackoverflow.com/a/49689589/261061))

Run this command to check that everything is installed correctly:

```
$ ./scripts/doctor.sh
docker 24.0.6 >= 24.0.6 installed ✅
psql installed ✅
pgcli installed ✅
```

See [`prerequisites.md`](prerequisites.md) to get more information on how to install this software.

## Services versions

- PostgreSQL 16
- [pgBackRest 2.49](https://github.com/pgbackrest/pgbackrest/releases/tag/release%2F2.49)

## Getting start

```sh
$ rtx install
$ docker compose build
```

I start Minio service:

```sh
$ docker compose up -d minio --wait
```

I create the S3 bucket in Minio:

```sh
$ mc mb pgbackrest/pgbackrest
Bucket created successfully `pgbackrest/`.
$ mc ls pgbackrest/
[2023-12-31 15:19:25 CET]     0B pgbackrest/
```

I start PostgreSQL database service:

```sh
$ docker compose up -d postgres1 --wait
```

I check that the PostreSQL and Minio services are running correctly:

```sh
$ docker compose ps --services --status running
minio
postgres1
```

I wait a few seconds to allow the command [`pgbackrest --stanza=instance1 --log-level-console=info stanza-create`](./docker-entrypoint.sh#19) to run.

I check that all has gone well with the following command:

```sh
$ ./scripts/pgbackrest.sh check
2023-12-31 17:22:55.912 P00   INFO: check command begin 2.49: --exec-id=2448-6736ba1a --log-level-console=info --log-level-file=info --pg1-path=/var/lib/postgresql/data --repo1-path=/repo --repo1-s3-bucket=pgbackrest --repo1-s3-endpoint=minio --repo1-s3-key=<redacted> --repo1-s3-key-secret=<redacted> --repo1-s3-region=us-east-1 --no-repo1-storage-verify-tls --repo1-type=s3 --stanza=instance1
2023-12-31 17:22:56.517 P00   INFO: check repo1 configuration (primary)
2023-12-31 17:22:56.724 P00   INFO: check repo1 archive for WAL (primary)
2023-12-31 17:22:56.726 P00   INFO: WAL segment 000000010000000000000011 successfully archived to '/repo/archive/instance1/16-1/0000000100000000/000000010000000000000011-12fd1b3f2c4d731ad623aad01a83dea308ea56ec.gz' on repo1
2023-12-31 17:22:56.726 P00   INFO: check command end: completed successfully (816ms)
```

I initialize the database with data:

```sh
$ ./scripts/seed.sh
$ ./scripts/generate_dummy_rows.sh
$ ./scripts/enter-in-pg1.sh
postgres@127:postgres> select * from public.dummy;
+----+-------------------------------+
| id | text                          |
|----+-------------------------------|
| 1  | 2023-12-30 14:04:31.763204+00 |
| 2  | 2023-12-30 14:04:31.763204+00 |
| 3  | 2023-12-30 14:04:31.763204+00 |
| 4  | 2023-12-30 14:04:31.763204+00 |
| 5  | 2023-12-30 14:04:31.763204+00 |
| 6  | 2023-12-30 14:04:31.763204+00 |
+----+-------------------------------+
SELECT 3
Time: 0.012s
```

Wait 60s, and check:

```sh
$ ./scripts/pg_stat_archiver.sh
 archived_count |    last_archived_wal     |      last_archived_time       | failed_count | last_failed_wal | last_failed_time |          stats_reset
----------------+--------------------------+-------------------------------+--------------+-----------------+------------------+-------------------------------
              9 | 00000001000000000000000F | 2023-12-31 17:05:23.143769+00 |            0 |                 |                  | 2023-12-31 16:00:46.015233+00
(1 ligne)

$ mc du pgbackrest
7.0MiB  1047 objects

$ ./scripts/table_sizes.sh
Database size:
 pg_size_pretty
----------------
 7580 kB
(1 ligne)

Table sizes:
 schema | table | total_size | data_size  | index_size | rows | total_row_size | row_size
--------+-------+------------+------------+------------+------+----------------+----------
 public | dummy | 32 kB      | 8192 bytes | 16 kB      |  110 | 295 bytes      | 73 bytes
(1 ligne)
```

```sh
$ ./scripts/pgbackrest.sh info
stanza: instance1
    status: ok
    cipher: none

    db (current)
        wal archive min/max (16): 000000010000000000000001/000000010000000000000012

        full backup: 20231231-155910F
            timestamp start/stop: 2023-12-31 15:59:10+00 / 2023-12-31 15:59:14+00
            wal start/stop: 000000010000000000000003 / 000000010000000000000004
            database size: 22MB, database backup size: 22MB
            repo1: backup set size: 2.9MB, backup size: 2.9MB

        incr backup: 20231231-155910F_20231231-155935I
            timestamp start/stop: 2023-12-31 15:59:35+00 / 2023-12-31 15:59:37+00
            wal start/stop: 000000010000000000000006 / 000000010000000000000007
            database size: 22MB, database backup size: 8.3KB
            repo1: backup set size: 2.9MB, backup size: 402B
            backup reference list: 20231231-155910F

        incr backup: 20231231-155910F_20231231-160049I
            timestamp start/stop: 2023-12-31 16:00:49+00 / 2023-12-31 16:00:50+00
            wal start/stop: 000000010000000000000009 / 00000001000000000000000A
            database size: 22.2MB, database backup size: 2.8MB
            repo1: backup set size: 2.9MB, backup size: 337.3KB
            backup reference list: 20231231-155910F, 20231231-155910F_20231231-155935I
```

## Simulate database restore in postgres2 instance

Stop `postgres2` instance and delete its volume:

```sh
$ docker compose stop postgres2
$ sudo rm -rf volumes/postgres2
```

Launch backup restoration to `postgres2` instance:

```sh
$ docker compose run --entrypoint=/restore.sh postgres2 restore
2023-12-31 19:04:53.617 P00   INFO: restore command begin 2.49: --delta --exec-id=21-cb3750eb --log-level-console=info --log-level-file=info --pg1-path=/var/lib/postgresql/data --process-max=2 --repo1-path=/repo --repo1-s3-bucket=pgbackrest --repo1-s3-endpoint=minio --repo1-s3-key=<redacted> --repo1-s3-key-secret=<redacted> --repo1-s3-region=us-east-1 --no-repo1-storage-verify-tls --repo1-type=s3 --stanza=instance1
WARN: --delta or --force specified but unable to find 'PG_VERSION' or 'backup.manifest' in '/var/lib/postgresql/data' to confirm that this is a valid $PGDATA directory. --delta and --force have been disabled and if any files exist in the destination directories the restore will be aborted.
2023-12-31 19:04:53.631 P00   INFO: repo1: restore backup set 20231231-155910F_20231231-185030I, recovery will start at 2023-12-31 18:50:30
2023-12-31 19:04:55.112 P00   INFO: write updated /var/lib/postgresql/data/postgresql.auto.conf
2023-12-31 19:04:55.130 P00   INFO: restore global/pg_control (performed last to ensure aborted restores cannot be started)
2023-12-31 19:04:55.132 P00   INFO: restore size = 22.2MB, file total = 971
2023-12-31 19:04:55.132 P00   INFO: restore command end: completed successfully (1516ms)
```

Start `postgres2` instance:

```sh
$ docker compose up -d postgres2
```

Launch backup restoration to `postgres2` instance:

```sh
$ docker compose stop postgres2
$ sudo rm -rf volumes/postgres2
$ docker compose run --entrypoint=/restore.sh postgres2 "--type=time --target='2024-01-01 21:02:00+00' restore"
$ docker compose up -d postgres2
$ ./scripts/enter-in-pg2.sh
postgres@127:postgres> select * from dummy order by id desc limit 10;
+-----+-------------------------------+
| id  | text                          |
|-----+-------------------------------|
| 132 | 2024-01-01 21:01:11.684139+00 |
| 131 | 2024-01-01 21:01:11.684139+00 |
| 130 | 2024-01-01 21:01:11.684139+00 |
| 129 | 2024-01-01 21:01:11.684139+00 |
| 128 | 2024-01-01 21:01:11.684139+00 |
| 127 | 2024-01-01 21:01:11.684139+00 |
| 126 | 2024-01-01 21:01:11.684139+00 |
| 125 | 2024-01-01 21:01:11.684139+00 |
| 124 | 2024-01-01 21:01:11.684139+00 |
| 123 | 2024-01-01 21:01:11.684139+00 |
+-----+-------------------------------+
SELECT 10
Time: 0.010s
$ docker compose stop postgres2
$ sudo rm -rf volumes/postgres2
$ docker compose run --entrypoint=/restore.sh postgres2 restore
$ docker compose up -d postgres2
$ ./scripts/enter-in-pg2.sh
postgres@127:postgres> select * from dummy order by id desc limit 10;
+-----+-------------------------------+
| id  | text                          |
|-----+-------------------------------|
| 143 | 2024-01-01 21:03:04.292911+00 |
| 142 | 2024-01-01 21:03:04.292911+00 |
| 141 | 2024-01-01 21:03:04.292911+00 |
| 140 | 2024-01-01 21:03:04.292911+00 |
| 139 | 2024-01-01 21:03:04.292911+00 |
| 138 | 2024-01-01 21:03:04.292911+00 |
| 137 | 2024-01-01 21:03:04.292911+00 |
| 136 | 2024-01-01 21:03:04.292911+00 |
| 135 | 2024-01-01 21:03:04.292911+00 |
| 134 | 2024-01-01 21:03:04.292911+00 |
+-----+-------------------------------+
SELECT 10
Time: 0.007s
```

Now, I test restoration on `postgre1` instance:

```
$ docker compose stop postgres1
$ sudo rm -rf volumes/postgres1
$ docker compose run --entrypoint=/restore.sh postgres1 "--type=time --target='2024-01-01 21:02:00+00' restore"
```

If you're not restoring the latest version of the database, but a past version, don't forget to change the value
of `PGBACKREST_REPO1_PATH` in the docker-compose so as not to continue writing to the previous backup (stanza).

```
$ docker compose up -d postgres1
$ ./scripts/enter-in-pg1.sh
postgres@127:postgres> select * from dummy order by id desc limit 10;
```

## Access to minio web console

Go to https://127.0.0.1:9001

Login, password: `minioadmin`|`minioadmin`


## Debug container

Here's how to enter the container built by [`Dockerfile`](./Dockerfile) without launching the ['docker-entrypoint.sh'](./docker-entrypoint.sh) and therefore the Postgres service:

```sh
$ docker compose run --rm --entrypoint bash postgres
root@847ef12886b3:/# pgbackrest version
pgBackRest 2.49
```

