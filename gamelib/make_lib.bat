@echo off
SET FLAGS=-O2 -Wall -Iinclude -Llib
gcc -c %FLAGS% src/gamelib.c
gcc -c %FLAGS% src/gamelib_image.c
gcc -c %FLAGS% src/gamelib_font.c
gcc -c %FLAGS% src/gamelib_sound.c
gcc -c %FLAGS% src/gamelib_rand.c
gcc -c %FLAGS% src/gamelib_internal.c
del lib\libgamelib.a 2> NUL
ar rcs lib/libgamelib.a gamelib.o
ar rcs lib/libgamelib.a gamelib_image.o
ar rcs lib/libgamelib.a gamelib_font.o
ar rcs lib/libgamelib.a gamelib_sound.o
ar rcs lib/libgamelib.a gamelib_rand.o
ar rcs lib/libgamelib.a gamelib_internal.o
ranlib lib/libgamelib.a
del *.o
