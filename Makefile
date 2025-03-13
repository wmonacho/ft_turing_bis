.PHONY: all clean

all: build
	./dist-newstyle/build/x86_64-linux/ghc-9.0.2/ft-turing-bis-0.1.0.0/x/ft-turing-bis/build/ft-turing-bis/ft-turing-bis machineExample/palindrome.json 010 

build:
	cabal build

clean:
	cabal clean