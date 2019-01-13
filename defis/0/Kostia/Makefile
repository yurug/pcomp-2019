CAMLC=ocamlbuild
MAIN=anagram
EXEC=anagram
COMMAND=$(CAMLC)

all: byte

byte:
	$(COMMAND) anagram.byte
	mv $(MAIN).byte $(EXEC)

native:
	$(COMMAND) anagram.native
	mv $(MAIN).native $(EXEC)

.PHONY: clean

clean:
	rm -f -R _build
	rm -f $(EXEC)
