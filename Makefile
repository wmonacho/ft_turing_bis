.PHONY: all clean

all: build
	cp ./dist-newstyle/build/x86_64-linux/ghc-9.4.8/ft-turing-bis-0.1.0.0/x/ft-turing-bis/build/ft-turing-bis/ft-turing-bis ft_turing

build:
	cabal build

clean:
	cabal clean
	rm ft_turing