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
Bucket created successfully `pgbackrest/pgbackrest`.
$ mc ls pgbackrest/pgbackrest
[2023-12-31 15:19:25 CET]     0B pgbackrest/
```

I start PostgreSQL database service:

```sh
$ docker compose up -d --wait
```

I check that the PostreSQL and Minio services are running correctly:

```sh
$ docker compose ps --services --status running
minio
postgres
```

I initialize the database with data:

```sh
$ ./scripts/seed.sh
$ ./scripts/generate_dummy_rows.sh
$ ./scripts/enter-in-pg.sh
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

## Access to minio web console

Go to https://127.0.0.1:9001

Login, password: `minioadmin`|`minioadmin`

## List files in Minio pgbackrest folder


## Debug container

Here's how to enter the container built by [`Dockerfile`](./Dockerfile) without launching the ['docker-entrypoint.sh'](./docker-entrypoint.sh) and therefore the Postgres service:

```sh
$ docker compose run --rm --entrypoint bash postgres
root@847ef12886b3:/# pgbackrest version
pgBackRest 2.49
```

