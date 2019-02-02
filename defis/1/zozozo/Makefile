all: build

build:
	dune build @fmt --auto-promote src/main.exe

clean:
	dune clean

clean_tests :
	rm tests/*/changes.txt tests/*/view0.csv tests/*/view_final.csv

test:
	dune runtest tests

.PHONY: all build clean test
