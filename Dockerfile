FROM debian:buster
RUN apt-get update && apt-get install --yes build-essential wget sudo unzip ssh
RUN groupadd -r raspbernetes && useradd -r -g raspbernetes raspbernetes
WORKDIR /raspbernetes
COPY raspbernetes/ raspbernetes/
COPY Makefile .
COPY mount.sh .
