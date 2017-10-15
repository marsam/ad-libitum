SCHEMEH=/usr/local/lib/csv9.4.1/ta6osx

all:
	cc -O3 -dynamiclib -Wl,-undefined -Wl,dynamic_lookup -I${SCHEMEH} -lsoundio -o libbridge.so chez-soundio/bridge.c
	cc -O3 -dynamiclib -Wl,-undefined -Wl,dynamic_lookup -I${SCHEMEH} -o sockets-stub.so chez-sockets/sockets-stub.c
	cc -O3 -dynamiclib -Wl,-undefined -Wl,dynamic_lookup -I${SCHEMEH} -o socket-ffi-values.so chez-sockets/socket-ffi-values.c

tangle:
	@ls *.org | parallel "./tangle.ss {}"

export:
	@./export.sh

precommit: tangle export

watch:
	@ls *.org | entr $(MAKE) tangle
