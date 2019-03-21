FROM debian:wheezy

MAINTAINER HU zhenlei

RUN apt-get update \
&& apt-get install -y scala

COPY donnees/*scala /home/
COPY docker_start.sh /home

RUN chmod 744 /home/docker_start.sh
ENTRYPOINT /home/docker_start.sh
WORKDIR /home
