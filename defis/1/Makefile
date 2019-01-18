EXEC=ws

all: build $(EXEC)

$(EXEC):
	ln -s _build/default/src/main.exe $(EXEC)

build:
	dune build @fmt --auto-promote src/main.exe

clean:
	dune clean
	rm -rf $(EXEC)

.PHONY: all build clean
