# syntax=docker/dockerfile:1.3
FROM mysql:8
LABEL Ken Ramsey="kramsey@jornada-vmail.nmsu.edu"
RUN --mount=type=secret,id=_env,src=/opt/docker/swhub-${PROJECT}.secrets/.env cat /etc/secrets/.env
EXPOSE 3306