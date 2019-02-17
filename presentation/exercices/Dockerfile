FROM archlinux/base

RUN pacman -Syyu --noconfirm
RUN pacman -S rust --noconfirm

WORKDIR /home/docker
COPY 1 /home/docker/1
COPY 2 /home/docker/2
COPY 3 /home/docker/3