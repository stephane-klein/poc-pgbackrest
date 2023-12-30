#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

# This functio come from https://github.com/mateusza/bash-version-compare
version_compare () {
    local va op vb vs vl
    va="$1"
    op="$2"
    vb="$3"
    case "$op" in
        lt|le|ge|gt|eq) ;;
        "")
            printf "missing operator\n" >&2
            return 2
            ;;
        *)
            printf "unknown operator: \"$op\"\n" >&2
            return 2
            ;;
    esac

    if [ -z "$va" ] || [ -z "$vb" ]; then
        printf "missing operand\n" >&2
        return 2
    fi

    if [ "$va" == "$vb" ]; then
        case "$op" in
            eq|le|ge)
                return 0 ;;
            *)
                return 1 ;;
        esac
    fi

    declare -a vs
    readarray -t vs < <(printf "%s\n%s\n" "$va" "$vb" | sort -V)
    vl="${vs[0]}"

    case "$op" in
        lt|le)
            [ "$va" == "$vl" ] && return 0 || return 1 ;;
        gt|ge)
            [ "$vb" == "$vl" ] && return 0 || return 1 ;;
    esac

    return 99
}

if [[ "$OSTYPE" =~ ^darwin ]]; then
    if [[ $(command -v docker) =~ "brew" ]]; then
        printf "brew installed ✅\n"
    else
        printf "Error: Homebrow is net installed\n\n"
        printf "How to fix the error? Follow https://brew.sh instructions or execute:\n"
        printf "  $ /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"\n\n"
    fi
else
    source /etc/os-release
fi

if [[ $(command -v rtx) =~ "rtx" ]]; then
    if (version_compare $(rtx version | cut -d" " -f1) ge "2023.11.4"); then
        printf "rtx 2023.11.4 >= %s installed ✅\n" $(rtx version | cut -d" " -f1)
    else
        if [[ "$OSTYPE" =~ ^darwin ]]; then
            printf "Error: rtx is not installed\n\n"
            printf "How to fix the error? Execute:\n\n"
            printf "  $ brew install rtx\n\n"
        fi

        if [[ "$ID" == fedora ]]; then
            printf "Error: rtx version %s is installed, but the project need version >= 2023.11.4 \n" $(rtx version | cut -d" " -f1)
            printf "How to fix the error? Follow https://github.com/jdx/rtx#dnf instructions or execute:\n\n"
            printf "  $ sudo dnf update -y rtx\n\n"
        fi
    fi
else
    if [[ "$OSTYPE" =~ ^darwin ]]; then
        printf "Error: rtx is not installed\n\n"
        printf "How to fix the error? Execute:\n\n"
        printf "  $ brew install rtx\n\n"
    fi

    if [[ "$ID" == fedora ]]; then
        printf "Error: rtx is not installed\n\n"
        printf "How to fix the error? Follow https://github.com/jdx/rtx#dnf instructions or execute:\n\n"
        printf "  $ sudo dnf -y install dnf-plugins-core\n"
        printf "  $ sudo sudo dnf config-manager --add-repo https://rtx.pub/rpm/rtx.repo\n"
        printf "  $ sudo dnf install -y rtx\n"
        exit 1
    fi
fi

if [[ $(command -v docker) =~ "docker" ]]; then
    if (version_compare $(docker version --format '{{.Client.Version}}') ge 24.0.6); then
        printf "docker 24.0.6 >= %s installed ✅\n" $(docker version --format '{{.Client.Version}}')
    else
        if [[ "$ID" == fedora ]]; then
            printf "Error: docker version %s is installed, but the project need version >= 24.0.6 \n\n" $(docker version --format '{{.Client.Version}}')
            printf "How to fix the error? Follow https://docs.docker.com/engine/install/fedora/ instruction or execute:\n\n"
            printf "  $ sudo dnf upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
        fi
    fi
else
    if [[ "$OSTYPE" =~ ^darwin ]]; then
        printf "Error: docker is not installed\n\n"
        printf "How to fix the error? Execute:\n\n"
        printf "  $ brew install docker\n\n"
    fi

    if [[ "$ID" == fedora ]]; then
        printf "Error: docker is not installed\n\n"
        printf "How to fix the error? Follow https://docs.docker.com/engine/install/fedora/ instruction or execute:\n\n"
        printf "  $ sudo dnf -y install dnf-plugins-core\n"
        printf "  $ sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo\n"
        printf "  $ sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin\n"
        printf "  $ sudo systemctl start docker\n"
        exit 1
    fi
fi

if [[ $(command -v psql) =~ psql ]]; then
    printf "psql installed ✅\n"
else
    if [[ "$OSTYPE" =~ ^darwin ]]; then
        printf "Error: psql is not installed\n\n"
        printf "How to fix this error? Execute:\n\n"
        printf "  $ brew install libpq\n"
        printf "  $ brew link --force libpq\n\n"
    fi
    if [[ "$ID" == fedora ]]; then
        printf "Error: psql is not installed\n\n"
        printf "How to fix this error? Execute:\n\n"
        printf "  $ sudo dnf install postgresql.x86_64\n\n"
    fi
fi

if [[ $(command -v pgcli) =~ pgcli ]]; then
    printf "pgcli installed ✅\n"
else
    printf "Error: pgcli is not installed\n\n"
    printf "How to fix this error? Execute:\n\n"
    printf "  $ pip install pgcli\n\n"
fi
