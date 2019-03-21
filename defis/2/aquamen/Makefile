
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
CP            := cp
EXEC          := ws
EXECDIR       := debug
LOGLVL        := trace

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
	LOGLVL     := error
endif

FLAGS       += $(FEATURES)

all: docker
	$(CP) scripts/ws.sh $(EXEC)

help:
	@echo "all      construit l'image docker"
	@echo "build    compile le code"
	@echo "test     compile et exécute les tests unitaires"
	@echo "run      exécute le programme avec les paramètre suivants"
	@echo "             - DATA le nom du tableur. Doit être dans le dossier tests/"
	@echo "             - USER le nom de 'user.txt'. Doit être dans le dossier tests/"
	@echo "             - VIEW le nom de 'view0.txt'. Sera généré dans le dossier tests/"
	@echo "             - CHANGE le nom de 'changes.txt'. Sera généré dans le dossier tests/"
	@echo "docker   construit l'image docker"
	@echo "perf     exécute le programme avec 'perf' pour avoir le temps d'exécution du programme"
	@echo "mrproper nettoye le dossier d'installation"

build:
	@mkdir -p data
	$(CC) $(FLAGS)

test:
	$(TEST)

run:
	RUST_LOG="$(LOGLVL)" $(RUN) $(FLAGS) tests/$(DATA) tests/$(USER) tests/$(VIEW) tests/$(CHANGE)

docker:
	docker build $(CLEAN) -t $(TARGET) .

perf: build
	@mkdir -p tests
	@echo "File size: " `du -sch tests/$(DATA)`
	RUST_LOG="$(LOGLVL)" $(TIME) ./target/$(EXECDIR)/$(TARGET) tests/$(DATA) tests/$(USER) tests/$(VIEW) tests/$(CHANGE)

mrproper:
	$(CLEANER)
	docker rm $(TARGET)
	$(RM) $(EXEC)
