/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspkerneltypes.h - PSP kernel types and definitions.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspkerneltypes.h 1884 2006-04-30 08:55:54Z chip $
 */

/* Note: Some of the structures, types, and definitions in this file were
   extrapolated from symbolic debugging information found in the Japanese
   version of Puzzle Bobble. */

module pspsdk.pspkerneltypes;

public import pspsdk.psptypes;

/** UIDs are used to describe many different kernel objects. */
alias int SceUID;

/* Misc. kernel types. */
alias uint SceSize;
alias int SceSSize;

alias ubyte SceUChar;
alias uint SceUInt;

/* File I/O types. */
alias int SceMode;
alias SceInt64 SceOff;
alias SceInt64 SceIores;


