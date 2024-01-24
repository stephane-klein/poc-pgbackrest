# Deploy PostgreSQL + pgbackrest services on Scaleway compute instance

```
$ cp .envrc.skel .envrc
```

Edit `.envrc`.

```
$ rxt install
$ terraform init
$ terraform apply
```

Get server public ip:

```
$ terraform show --json | jq '.values.root_module.resources[] | select(.address=="scaleway_instance_server.server1") | .values.public_ip' -r
```

```sh
$ ./scripts/install_basic_server_configuration.sh
$ ./scripts/deploy_postgres.sh
$ ./scripts/open_ssh_tunnel_to_postgres.sh
$ ./scripts/seed.sh
$ ./scripts/generate_dummy_rows.sh
```

Some command to check bucket is working properly:

```sh
$ mc ls scaleway/pgbackrest-backup-bucket2/
[2024-01-22 22:44:47 CET]     0B repo/
```

```sh
postgres@127:postgres> select * from dummy order by id desc limit 4;
+----+-------------------------------+
| id | text                          |
|----+-------------------------------|
| 44 | 2024-01-22 21:26:25.131294+00 |
| 43 | 2024-01-22 21:26:25.131294+00 |
| 42 | 2024-01-22 21:26:25.131294+00 |
| 41 | 2024-01-22 21:26:25.131294+00 |
+----+-------------------------------+
SELECT 4
Time: 0.021s
```

```sh
$ mc du scaleway/pgbackrest-backup-bucket2/
19MiB   2254 objects    pgbackrest-backup-bucket2
```

Now I want to restore PostgreSQL backup on local Docker container instance.

First, I check bucket configuration in Postgres3 container instance: 

```
$ docker compose run --entrypoint=/restore.sh postgres3 info
...
```

Launch restoration:

```
$ docker compose run --entrypoint=/restore.sh postgres3 restore
2024-01-22 21:54:37.435 P00   INFO: write updated /var/lib/postgresql/data/postgresql.auto.conf
2024-01-22 21:54:37.447 P00   INFO: restore global/pg_control (performed last to ensure aborted restores cannot be started)
2024-01-22 21:54:37.449 P00   INFO: restore size = 22.2MB, file total = 971
2024-01-22 21:54:37.450 P00   INFO: restore command end: completed successfully (42124ms)
```

Execute this command if you want delete bucket content:

```
$ mc rm --versions -r --force scaleway/pgbackrest-backup-bucket2/
Created delete marker `scaleway/pgbackrest-backup-bucket/folder1/README.md` (versionId=4_z46edf6c8e6fa0bd883d50512_f429eb8f66228b517_d20240115_m163102_c003_v7007000_t0000_u01705336262970).
```
