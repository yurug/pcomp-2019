
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
else
	FLAGS      += --release
endif

FLAGS       += $(FEATURES)

all: docker
	$(CP) ws.sh $(EXEC)

build:
	$(CC) $(FLAGS)

test:
	$(TEST)

run:
	$(RUN) $(FLAGS) $(DATA) $(USER) $(VIEW) $(CHANGE)

docker:
	docker build $(CLEAN) -t $(TARGET) .

perf: # FIXME check /usr/bin/time format string
	@echo "File size: " `du -sch $(DATA)`
	@$(TIME) $(RUN) $(FALGS) $(DATA) $(USER) $(VIEW) $(CHANGE)

mrproper:
	$(CLEANER)
	docker rm $(TARGET)
	$(RM) $(EXEC)
