# syntax=docker/dockerfile:1.5
FROM mysql:8
COPY src/site-db.sql.gz /docker-entrypoint-initdb.d
RUN --mount=type=secret,id=mysql_root --mount=type=secret,id=mysql_db --mount=type=secret,id=mysql_usr --mount=type=secret,id=mysql_pw
EXPOSE 3306