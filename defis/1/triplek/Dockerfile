FROM archlinux/base

RUN pacman -Syyu --noconfirm
RUN pacman -S gcc --noconfirm
RUN pacman -S jdk-openjdk --noconfirm
RUN pacman -S scala --noconfirm
RUN pacman -S git --noconfirm
RUN pacman -S make --noconfirm

WORKDIR /home/triplek
RUN git clone https://github.com/yurug/pcomp-2019.git
WORKDIR /home/triplek/pcomp-2019/
RUN git checkout -b triplek origin/triplek
RUN git pull
WORKDIR /home/triplek/pcomp-2019/defis/1/triplek