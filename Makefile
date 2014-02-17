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
lib_build_params= -I../out/di ../out/webcaret.a ../out/couched.a

build: deeq-api

run: deeq-api
	out/./deeq-api

deeq-api: lib/*.d deps/webcaret/out deps/couche.d/out
	mkdir -p out
	cd lib; $(DC) -of../out/deeq-api -op app.d $(lib_build_params) $(DFLAGS)
	out/./deeq-api

.PHONY: clean

deps/webcaret/out:
	@echo "Compiling deps/webcaret"
	#git submodule update --init deps/webcaret
	#(cd deps/webcaret; git checkout master)
	#(cd deps/webcaret; git pull origin master)
	mkdir -p out
	DEBUG=${DEBUG} $(MAKE) -C deps/webcaret clean
	DEBUG=${DEBUG} $(MAKE) -n -C deps/webcaret
	cp deps/webcaret/out/webcaret.a out/
	cp -r deps/webcaret/out/di/ out/di

deps/couche.d/out:
	@echo "Compiling deps/couche.d"
	#git submodule update --init deps/couche.d
	#(cd deps/couche.d; git checkout master)
	#(cd deps/couche.d; git pull origin master)
	mkdir -p out
	DEBUG=${DEBUG} $(MAKE) -C deps/couche.d clean
	DEBUG=${DEBUG} lib_build_params="-I../../../out/di ../../../out/webcaret.a" $(MAKE) -n -C deps/couche.d compile
	cp deps/couche.d/out/couched.a out/
	cp -r deps/couche.d/out/di/ out/di

clean:
	rm -rf out/*
	rm -rf deps/*
