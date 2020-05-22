#!/usr/bin/env bash

GITHUB_USER=
GITHUB_OWNER=
GITHUB_REPOSITORY=

cat ~/TOKEN.txt | docker login docker.pkg.github.com -u $GITHUB_USER --password-stdin

docker build -t docker.pkg.github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/frontend:latest frontend/.
docker build -t docker.pkg.github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/consumer:latest consumer/.
docker build -t docker.pkg.github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/producer:latest producer/.
docker build -t docker.pkg.github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/stock:latest stock/.

docker push docker.pkg.github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/frontend:latest
docker push docker.pkg.github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/consumer:latest
docker push docker.pkg.github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/producer:latest
docker push docker.pkg.github.com/$GITHUB_OWNER/$GITHUB_REPOSITORY/stock:latest
