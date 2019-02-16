.PHONY: clean all

all:
	ocamlopt -o generate -O3 unix.cmxa generate.ml

big: all
	./generate 1000 20000

clean:
	rm big.csv generate
