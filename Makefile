.PHONY: all clean

all: build
	cabal exec ft-turing-bis machineExample/unary_sub.json

build:
	cabal build

clean:
	cabal clean