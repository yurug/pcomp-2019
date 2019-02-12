
TARGET        := aquamen
CARGO         := cargo
FLAGS         :=
FEATURES      :=
CLEAN         :=
TIME          := time -v
TEST          := $(CARGO) test
CC            := $(CARGO) build
RUN           := $(CARGO) run
CLEANER       := $(CARGO) clean
CP            := $(CP)
EXEC          := ws
EXECDIR       := debug

#==================================
# Don't edit below this line
#==================================

ifeq ($(BENCH), 1)
	FEATURES    += --features bench
else
	FEATURES		+=
endif

ifeq ($(NOCACHE), 1)
	CLEAN	      := --no-cache
else
	CLEAN	      :=
endif

ifeq ($(DEBUG), 1)
	FLAGS      +=
	EXECDIR    := debug
else
	FLAGS      += --release
	EXECDIR    := release
endif

FLAGS       += $(FEATURES)

all: docker
	$(CP) scripts/ws.sh $(EXEC)

build:
	$(CC) $(FLAGS)

test:
	$(TEST)

run:
	$(RUN) $(FLAGS) $(DATA) $(USER) $(VIEW) $(CHANGE)

docker:
	docker build $(CLEAN) -t $(TARGET) .

perf: build # FIXME check /usr/bin/time format string
	@mkdir -p tests
	@echo "File size: " `du -sch tests/$(DATA)`
	RUST_LOG="trace" $(TIME) ./target/$(EXECDIR)/$(TARGET) tests/$(DATA) tests/$(USER) tests/$(VIEW) tests/$(CHANGE)

mrproper:
	$(CLEANER)
	docker rm $(TARGET)
	$(RM) $(EXEC)
