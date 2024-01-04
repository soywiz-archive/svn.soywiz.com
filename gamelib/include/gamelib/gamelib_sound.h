#ifndef __GAMELIB_SOUND_H
#define __GAMELIB_SOUND_H

#ifdef __cplusplus
extern "C" {
#endif

typedef Mix_Music* Music;
typedef Mix_Chunk* Sound;
typedef int        Channel;

extern Channel freeChanel;

Music MusicLoadFromFile(char *filename);
int   MusicPlay(Music m);
int   MusicPlayEx(Music m, int loops, int fadems, int position);
void  MusicFadeOut(int ms);
void  MusicStop();
void  MusicSetVolume(float v);
float MusicGetVolume();
void  MusicFree(Music m);

Sound SoundLoadFromStreamEx(Stream s, int freesrc);
Sound SoundLoadFromStream(Stream s);
Sound SoundLoadFromMemory(void *ptr, int length);
Sound SoundLoadFromFile(char *filename);
void  SoundFree(Sound s);

Channel SoundPlay(Sound s);
Channel SoundPlayEx(Sound s, Channel channel, int loops, int fadems, int ticks);


void ChannelPause(Channel c);
void ChannelResume(Channel c);
void ChannelStop(Channel c);
void ChannelStopAfter(Channel c, int ms);
void ChannelFadeOut(Channel c, int ms);
bool ChannelIsPlaying(Channel c);

#ifdef __cplusplus
}
#endif

#endif
