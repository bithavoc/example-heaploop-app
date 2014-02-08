DC=dmd
OS_NAME=$(shell uname -s)
MH_NAME=$(shell uname -m)
DFLAGS=
ifeq (${DEBUG}, 1)
	DFLAGS=-debug -gc -gs -g
else
	DFLAGS=-O -release -inline -noboundscheck
endif
ifeq (${OS_NAME},Darwin)
	DFLAGS+=-L-framework -LCoreServices 
endif
lib_build_params= -I../out/di ../out/webcaret.a

build: deeq-api

run: cleandeps deeq-api
	out/./deeq-api

deeq-api: lib/**/*.d deps/webcaret
	mkdir -p out
	cd lib; $(DC) -of../out/deeq-api -op app.d $(lib_build_params) $(DFLAGS)
	out/./deeq-api

cleandeps:
	rm -rf deps/*

.PHONY: clean cleandeps

deps/webcaret:
	@echo "Compiling deps/webcaret"
	git submodule update --init --remote deps/webcaret
	mkdir -p out
	DEBUG=${DEBUG} $(MAKE) -C deps/webcaret clean
	DEBUG=${DEBUG} $(MAKE) -C deps/webcaret
	cp deps/webcaret/out/webcaret.a out/
	cp -r deps/webcaret/out/di/ out/di

clean:
	rm -rf out/*
	rm -rf deps/*
