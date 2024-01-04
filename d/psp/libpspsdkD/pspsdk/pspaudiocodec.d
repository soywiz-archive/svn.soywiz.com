/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspaudiocodec.h - Prototypes for the sceAudiocodec library.
 *
 * Copyright (c) 2006 hitchhikr
 *
 * $Id: pspaudiocodec.h 2341 2007-12-06 20:05:52Z raphael $
 */
module pspsdk.pspaudiocodec;

extern (C) {


int sceAudiocodecCheckNeedMem(ulong *Buffer, int Type);
int sceAudiocodecInit(ulong *Buffer, int Type);
int sceAudiocodecDecode(ulong *Buffer, int Type);
int sceAudiocodecGetEDRAM(ulong *Buffer, int Type);
int sceAudiocodecReleaseEDRAM(ulong *Buffer);


}

