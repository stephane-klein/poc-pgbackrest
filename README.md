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
$ docker compose up -d --wait
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

## Access to minio web console

Go to https://127.0.0.1:9001

Login, password: `minioadmin`|`minioadmin`

## List files in Minio pgbackrest folder

```
$ mc mb pgbackrest/pgbackrest
Bucket created successfully `pgbackrest/pgbackrest`.
$ mc ls pgbackrest/pgbackrest
[2023-12-31 15:19:25 CET]     0B pgbackrest/
```

## Debug container

Here's how to enter the container built by [`Dockerfile`](./Dockerfile) without launching the ['docker-entrypoint.sh'](./docker-entrypoint.sh) and therefore the Postgres service:

```sh
$ docker compose run --rm --entrypoint bash postgres
root@847ef12886b3:/# pgbackrest version
pgBackRest 2.49
```

