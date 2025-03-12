.PHONY: all clean

all: build
	# ./dist-newstyle/build/x86_64-linux/ghc-9.4.8/ft-turing-bis-0.1.0.0/x/ft-turing-bis/build/ft-turing-bis/ft-turing-bis machineExample/unary_sub.json 111-11= 
	cabal run exes machineExample/unary_sub.json 111

build:
	cabal build

clean:
	cabal clean