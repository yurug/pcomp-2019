
FLAGS         := 

ifeq ($(DEBUG), 1)
	FLAGS +=
else
	FLAGS += --release
endif

all:
	cargo build $(FLAGS)

test:
	cargo test

run:
	cargo run
