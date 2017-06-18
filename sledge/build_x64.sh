#!/bin/sh

if [ `uname` = "Darwin" ] ; then
    CFLAGS="${CFLAGS} -I/opt/local/include -L/opt/local/lib -framework Cocoa"
fi

cc -g -o sledge --std=gnu99 -Wall -Wextra -O1 -I. ${CFLAGS} sledge.c readline.c reader.c writer.c alloc.c strmap.c stream.c ../devices/sdl2.c ../devices/posixfs.c -lm -lreadline -DREADLINE -lSDL2 -DCPU_X64 -DDEV_SDL -DDEV_POSIXFS

