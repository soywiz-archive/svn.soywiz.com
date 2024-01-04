#ifndef __GAMELIB_H
#define __GAMELIB_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include <SDL/SDL.h>
#include <SDL/SDL_image.h>
#include <SDL/SDL_mixer.h>
#include <SDL/SDL_ttf.h>
#include <SDL/SDL_opengl.h>
#include <SDL/SDL_net.h>

#ifdef WINDOWS
#include <windows.h>
#endif

#define bool int
#define false 0
#define true (!false)
#define null NULL

#undef main
#define main gamelib_main

typedef SDL_RWops* Stream;

#include "gamelib_image.h"
#include "gamelib_font.h"
#include "gamelib_sound.h"
#include "gamelib_rand.h"

extern SDL_Surface *_screen;
extern char key[SDLK_LAST];
extern int  keyv[SDLK_LAST];
extern char RequestExit;
extern int  AutoExitAtRequest;
extern int  FPS;

extern int screenWidth, screenHeight;
extern int screenWidthReal, screenHeightReal;

typedef struct { int x, y, b, pb, rb; } MouseStatus;

extern MouseStatus mouse;

// Funciones de inicialización y finalización
void GameInit();
void GameQuit();

// Funciones relativas al teclado
void KeyboardUpdate();
void KeyboardSetDelay(int delay, int interval);

// Funciones relativas al modo gráfico
void VideoModeSetTitle(char *title);
void VideoModeSetEx(int widthScreen, int heightScreen, int widthDraw, int heightDraw, int windowed);
void VideoModeSet(int width, int height, int windowed);
void VideoModeFrame();
void VideoModeEnable2D();
void VideoModeDisable2D();
void VideoModeSetFPS(int fps);
int  VideoModeGetFPS();

void DrawClear();

void ColorSet(float r, float g, float b, float a);

#define _esc    SDLK_ESCAPE
#define _enter  SDLK_RETURN
#define _return SDLK_RETURN
#define _left   SDLK_LEFT
#define _up     SDLK_UP
#define _down   SDLK_DOWN
#define _right  SDLK_RIGHT
#define _a      SDLK_a
#define _b      SDLK_b
#define _c      SDLK_c
#define _d      SDLK_d
#define _e      SDLK_e
#define _f      SDLK_f
#define _g      SDLK_g
#define _h      SDLK_h
#define _i      SDLK_i
#define _j      SDLK_j
#define _k      SDLK_k
#define _l      SDLK_l
#define _m      SDLK_m
#define _n      SDLK_n
#define _o      SDLK_o
#define _p      SDLK_p
#define _q      SDLK_q
#define _r      SDLK_r
#define _s      SDLK_s
#define _t      SDLK_t
#define _u      SDLK_u
#define _v      SDLK_v
#define _w      SDLK_w
#define _x      SDLK_x
#define _y      SDLK_y
#define _z      SDLK_z

#ifdef __cplusplus
}
#endif


#endif
