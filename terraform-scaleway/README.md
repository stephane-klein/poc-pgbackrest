# Terraform configuration for Scaleway Object storage

```
$ cp .envrc.skel .envrc
```

Edit `.envrc`.

```
$ rxt install
$ terraform init
$ terraform apply
```

Some command to check bucket is working properly:

```sh
$ mc ls scaleway
[2024-01-15 22:34:51 CET]     0B pgbackrest-backup-bucket/
```

```sh
$ mc cp README.md scaleway/pgbackrest-backup-bucket/folder1/
...ackrest/README.md: 9.54 KiB / 9.54 KiB ━━━━━━━━━━━━ 15.95 KiB/s 0s
```

```sh
$ mc tree scaleway/pgbackrest-backup-bucket/
scaleway/pgbackrest-backup-bucket/
└─ folder1
```

```sh
$ mc ls scaleway/pgbackrest-backup-bucket/folder1/
[2024-01-16 08:20:17 CET] 9.5KiB STANDARD README.md
```

```
$ mc rm --versions -r --force scaleway/pgbackrest-backup-bucket/
Created delete marker `scaleway/pgbackrest-backup-bucket/folder1/README.md` (versionId=4_z46edf6c8e6fa0bd883d50512_f429eb8f66228b517_d20240115_m163102_c003_v7007000_t0000_u01705336262970).
```
