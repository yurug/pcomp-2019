
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
	@time --format="%J   %U  user %S system %P cpu %*E total \n\
	avg shared (code):         %X KB \n\
	avg unshared (data/stack): %D KB \n\
	total (sum):               %K KB \n\
	max memory:                %M MB \n\
	page faults from disk:     %F \n\
	other page faults:         %R" cargo run $(DATA) $(USER) $(VIEW) $(CHANGE)

mrproper:
	cargo clean
	$(RM) ws
