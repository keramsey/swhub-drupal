# syntax=docker/dockerfile:1.2
FROM mysql:8.0.32
LABEL Ken Ramsey="kramsey@jornada-vmail.nmsu.edu"
RUN --mount=type=secret,id=_env,src=/opt/docker/swhub-${PROJECT}.secrets/.env cat /etc/secrets/.env
EXPOSE 3306