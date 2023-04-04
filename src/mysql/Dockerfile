# syntax = docker/dockerfile:1.3
FROM mysql:8.0.32
LABEL Ken Ramsey="kramsey@jornada-vmail.nmsu.edu"
RUN --mount=type=secret,id=_env,dst=/etc/secrets/.env cat /etc/secrets/.env
COPY site-db.sql.gz /docker-entrypoint-initdb.d
EXPOSE 3306