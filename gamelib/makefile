FLAGS=-O2 -Wall -Iinclude
INCLUDE1=-Iwin
LIB1=-Lwin
CC=gcc
AR=ar
RANLIB=ranlib

all: gamelib examples

examples: gamelib
	$(CC) $(LIB1) $(INCLUDE1) examples/simples.c -obin/simple -lgamelib -lSDL -lSDL_mixer -lSDL_net -lSDL_image -lSDL_ttf
	
gamelib: lib/libgamelib.a
	$(CC) $(FLAGS) $(INCLUDE1) -c src/gamelib.c
	$(CC) $(FLAGS) $(INCLUDE1) -c src/gamelib_font.c
	$(CC) $(FLAGS) $(INCLUDE1) -c src/gamelib_image.c
	$(CC) $(FLAGS) $(INCLUDE1) -c src/gamelib_sound.c
	$(CC) $(FLAGS) $(INCLUDE1) -c src/gamelib_rand.c
	$(CC) $(FLAGS) $(INCLUDE1) -c src/gamelib_internal.c
	$(AR) rcs lib/libgamelib.a gamelib.o
	$(AR) rcs lib/libgamelib.a gamelib_font.o
	$(AR) rcs lib/libgamelib.a gamelib_image.o
	$(AR) rcs lib/libgamelib.a gamelib_sound.o
	$(AR) rcs lib/libgamelib.a gamelib_rand.o
	$(AR) rcs lib/libgamelib.a gamelib_internal.o
	$(RANLIB) lib/libgamelib.a
	