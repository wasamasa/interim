
gcc -m32 -g -o sledge --std=gnu99 -Wall -Wextra -I. sledge.c readline.c reader.c writer.c alloc.c strmap.c stream.c ../devices/posixfs.c ../devices/sdl2.c -lm -lreadline -DREADLINE -lSDL2 -DCPU_X86 -DDEV_SDL -DDEV_POSIXFS

