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
lib_build_params=../out/heaploop.a ../out/webcaret-router.a -I../out/di ../deps/heaploop/out/duv.a ../deps/heaploop/out/uv.a ../deps/heaploop/out/http-parser.a ../deps/heaploop/out/events.d.a

build: deeq-api

run: cleandeps deeq-api
	out/./deeq-api

deeq-api: lib/**/*.d deps/heaploop deps/webcaret-router
	mkdir -p out
	cd lib; $(DC) -of../out/deeq-api -op app.d webcaret/*.d $(lib_build_params) $(DFLAGS)

cleandeps:
	rm -rf deps/*

.PHONY: clean cleandeps

deps/heaploop:
	@echo "Compiling deps/heaploop"
	git submodule update --init --remote deps/heaploop
	rm -rf deps/heaploop/deps/duv
	rm -rf deps/heaploop/deps/events.d
	rm -rf deps/heaploop/deps/http-parser.d
	mkdir -p out
	DEBUG=${DEBUG} $(MAKE) -C deps/heaploop
	cp deps/heaploop/out/heaploop.a out/
	cp -r deps/heaploop/out/di/ out/di

deps/webcaret-router:
	@echo "Compiling deps/webcaret-router"
	git submodule update --init --remote deps/webcaret-router
	rm -rf deps/webcaret-router/deps/events.d
	mkdir -p out
	(cd deps/webcaret-router ; DEBUG=${DEBUG} $(MAKE) )
	cp deps/webcaret-router/out/webcaret-router.a out/
	cp -r deps/webcaret-router/out/di/ out/di

clean:
	rm -rf out/*
	rm -rf deps/*
