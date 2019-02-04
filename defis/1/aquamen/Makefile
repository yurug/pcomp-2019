
TARGET        := aquamen
FLAGS         :=
CLEAN         :=

ifeq ($(NOCACHE), 1)
	CLEAN	:= --no-cache
else
	CLEAN	:=
endif

ifeq ($(DEBUG), 1)
	FLAGS +=
else
	FLAGS += --release
endif

all: docker
	cp run.sh ws

build:
	cargo build $(FLAGS)

test:
	cargo test

run:
	cargo run $(DATA) $(USER) $(VIEW) $(CHANGE)

docker:
	docker build $(CLEAN) -t $(TARGET) .

perf: # FIXME check /usr/bin/time format string
	time -v cargo run $(DATA) $(USER) $(VIEW) $(CHANGE)

mrproper:
	cargo clean
	$(RM) ws
