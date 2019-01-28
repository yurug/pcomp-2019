all: build

build:
	dune build @fmt --auto-promote src/main.exe

clean:
	dune clean

test:
	dune runtest tests

.PHONY: all build clean test
