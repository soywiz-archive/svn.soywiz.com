/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspiofilemgr_fcntl.h - File control definitions.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspiofilemgr_fcntl.h 559 2005-07-09 08:47:52Z mrbrown $
 */
module pspsdk.pspiofilemgr_fcntl;

/* Note: Not all of these sceIoOpen() flags are not compatible with the
   open() flags found in sys/unistd.h. */
const int PSP_O_RDONLY=	0x0001;
const int PSP_O_WRONLY=	0x0002;
const int PSP_O_RDWR=	(PSP_O_RDONLY | PSP_O_WRONLY);
const int PSP_O_NBLOCK=	0x0004;
const int PSP_O_DIROPEN=0x0008;	// Internal use for dopen
const int PSP_O_APPEND=	0x0100;
const int PSP_O_CREAT=	0x0200;
const int PSP_O_TRUNC=	0x0400;
const int PSP_O_EXCL=	0x0800;
const int PSP_O_NOWAIT=	0x8000;

const int PSP_SEEK_SET=	0;
const int PSP_SEEK_CUR=	1;
const int PSP_SEEK_END=	2;


