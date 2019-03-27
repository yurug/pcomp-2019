all: build

build:
	dune build @fmt --auto-promote src/main.exe

clean:
	dune clean

clean_tests :
	rm -f tests/*/changes.txt tests/*/view0.csv tests/*/view_final.csv tests/*/data_0.csv 0* 1* 2* 3* 4* 5* 6* 7* 8* 9*

test:
	dune runtest tests

.PHONY: all build clean test
