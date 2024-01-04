@echo off
set FLAGS=-O2 -Wall -Iinclude -Llib -Dmain=SDL_main
set LIBS=-lgamelib -lopengl32 -lSDLmain -lSDL.dll -lSDL_net -lSDL_mixer -lSDL_ttf -lSDL_image
gcc.exe %FLAGS% examples\simple.c -obin\simple.exe %LIBS%
