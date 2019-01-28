FROM archlinux/base

RUN pacman -Suy --noconfirm
RUN pacman -S --noconfirm --needed base-devel opam git
RUN useradd -m zozozo
USER zozozo
RUN opam init --disable-sandboxing
RUN eval $(opam env)
RUN opam install -y dune odoc ocamlformat utop
RUN eval $(opam env)

WORKDIR /home/zozozo
RUN git clone https://github.com/yurug/pcomp-2019.git
WORKDIR /home/zozozo/pcomp-2019
RUN git checkout zozozo
WORKDIR /home/zozozo/pcomp-2019/defis/1/zozozo
