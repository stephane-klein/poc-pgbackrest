# Prerequisites

- [Docker Engine](https://docs.docker.com/engine/) (tested with `24.0.6`)
- [pgcli](https://www.pgcli.com/)
- `psql` (More info about `psql` [brew package](https://stackoverflow.com/a/49689589/261061))

## Installation on MacOS

Install [Homebrew](https://brew.sh) with this command:

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Install Docker and `psql`:

```sh
$ brew install docker libpq
$ brew link --force libpq
```

Execute this command to install `pgcli`:

```sh
$ pip install pgcli
```

### Installation on Fedora

 or execute
To install [Docker Engine](https://docs.docker.com/engine/)  `docker compose` follow [Install Docker Engine on Fedora](https://docs.docker.com/engine/install/fedora/) instructions or execute:
```
$ sudo dnf -y install dnf-plugins-core\n"
$ sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo\n"
$ sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\n"
$ sudo systemctl start docker\n"
```
Execute this command to install `psql`:

```sh
$ sudo dnf install postgresql.x86_64
```

(Note: this `postgresql.x86_64` contains only PostgreSQL client utils, like `psql`)

Execute this command to install `pgcli`:

```sh
$ pip install pgcli
```

### check that everything is correctly installed

```sh
$ ./scripts/doctor.sh
docker 24.0.6 >= 24.0.6 installed ✅
psql installed ✅
pgcli installed ✅
```
