#include <gamelib/gamelib.h>
#include "gamelib_internal.h"

Channel freeChanel = -1;

Music MusicLoadFromFile(char *filename) { return Mix_LoadMUS(filename); }
void  MusicFree(Music m) { if (m) Mix_FreeMusic(m); }
int   MusicPlay(Music m) { return Mix_PlayMusic(m, 0); }
int   MusicPlayEx(Music m, int loops, int fadems, int position) { return Mix_FadeInMusicPos(m, loops, fadems, position); }
void  MusicFadeOut(int ms) { Mix_FadeOutMusic(ms); }
void  MusicStop() { Mix_HaltMusic(); }
void  MusicSetVolume(float v) { Mix_VolumeMusic((int)(v * 128)); }
float MusicGetVolume() { return ((float)Mix_VolumeMusic(-1)) / 128; }

Sound   SoundLoadFromStreamEx(Stream s, int freesrc) { return Mix_LoadWAV_RW(s, freesrc); }
Sound   SoundLoadFromStream(Stream s) { return SoundLoadFromStreamEx(s, 0); }
Sound   SoundLoadFromMemory(void *ptr, int length) { return SoundLoadFromStreamEx(SDL_RWFromMem(ptr, length), 1); }
Sound   SoundLoadFromFile(char *filename) { return SoundLoadFromStreamEx(SDL_RWFromFile(filename, "rb"), 1); }
void    SoundFree(Sound s)       { if (!s) Mix_FreeChunk(s); }

Channel SoundPlay(Sound s) { return Mix_PlayChannel(-1, s, 0); }
Channel SoundPlayEx(Sound s, Channel channel, int loops, int fadems, int ticks) { return Mix_FadeInChannelTimed(channel, s, loops, fadems, ticks); }

void ChannelPause(Channel c)  { Mix_Pause(c); }
void ChannelResume(Channel c) { Mix_Resume(c); }
void ChannelStop(Channel c)   { Mix_HaltChannel(c); }
void ChannelStopAfter(Channel c, int ms) { Mix_ExpireChannel(c, ms); }
void ChannelFadeOut(Channel c, int ms) { Mix_FadeOutChannel(c, ms); }
bool ChannelIsPlaying(Channel c) { return (Mix_Playing(c) != 0); }
