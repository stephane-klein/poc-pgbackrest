# POC pgBackRest

Repository starting point issue (in French): https://github.com/stephane-klein/backlog/issues/322

## Prerequisites

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

## Getting start

```sh
$ docker compose up -d --wait
$ ./scripts/seed.sh
$ ./scripts/fixtures.sh
$ ./scripts/enter-in-pg.sh
postgres@127:postgres> select * from public.users;
+----+----------+
| id | username |
|----+----------|
| 1  | user1    |
| 2  | user2    |
| 3  | user3    |
+----+----------+
SELECT 3
Time: 0.012s
```
