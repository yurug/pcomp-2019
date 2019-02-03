
TARGET        := aquamen
FLAGS         :=
CLEAN         :=

ifeq ($(DEBUG), 1)
	FLAGS +=
	CLEAN	:= --no-cache
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
	cargo run $(DATA) $(USER) $(VIEW) $(CHANGE)

docker:
	docker build ${CLEAN} -t ${TARGET} .

