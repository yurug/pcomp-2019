
FLAGS         := 

ifeq ($(DEBUG), 1)
	FLAGS +=
else
	FLAGS += --release
endif

all: docker
	cp ws.sh ws

build:
	cargo build $(FLAGS)

test:
	cargo test

run:
	cargo run
