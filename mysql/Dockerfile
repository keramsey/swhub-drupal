# syntax=docker/dockerfile:1.5
FROM mysql:8
LABEL Ken Ramsey="kramsey@jornada-vmail.nmsu.edu"
RUN --mount=type=secret,id=_env,target=/opt/docker/swhub-${PROJECT}/.secrets/.env cat /run/secrets/_env
EXPOSE 3306