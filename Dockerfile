FROM postgres:16

COPY --from=hairyhenderson/gomplate:stable /gomplate /bin/gomplate

RUN apt update -y && \
    apt install -y pgbackrest curl

ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /tini
RUN chmod +x /tini

# Latest releases available at https://github.com/aptible/supercronic/releases
ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.2.29/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64

RUN curl -fsSLO "$SUPERCRONIC_URL" \
 && chmod +x "$SUPERCRONIC" \
 && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
 && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

COPY crontab /crontab
COPY pgbackrest.conf.tmpl /etc/pgbackrest.conf.tmpl
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
COPY ./pgbackrest.sh /pgbackrest.sh

ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
