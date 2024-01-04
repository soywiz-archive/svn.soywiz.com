/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspvideocodec.h - Prototypes for the sceVideocodec library.
 *
 * Copyright (c) 2007 cooleyes
 *
 * $Id: pspvideocodec.h 2341 2007-12-06 20:05:52Z raphael $
 */
 
module pspsdk.pspvideocodec;


extern (C) {


int sceVideocodecOpen(uint *Buffer, int Type);
int sceVideocodecGetEDRAM(uint *Buffer, int Type);
int sceVideocodecInit(uint *Buffer, int Type);
int sceVideocodecDecode(uint *Buffer, int Type);
int sceVideocodecReleaseEDRAM(uint *Buffer);


}



