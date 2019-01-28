FROM debian:9

RUN apt-get update \
    && apt-get install -y \
        cargo

COPY src /home/docker
COPY Cargo.toml /home/docker

RUN {cd /home/docker; cargo build --release}

ENTRYPOINT /home/docker/target/release/aquamen
WORKDIR /home/docker
