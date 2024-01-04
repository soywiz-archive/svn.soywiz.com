/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspmoduleexport.h - Definitions for the .rodata.sceResident section.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspmoduleexport.h 1095 2005-09-27 21:02:16Z jim $
 */

module pspsdk.pspmoduleexport;

/** Structure to hold a single export entry */
struct _PspLibraryEntry {
	byte *	name;
	ushort	version_; // 'version' is a D reserved word!!
	ushort	attribute;
	ubyte	entLen;
	ubyte	varCount;
	ushort	funcCount;
	void *	entrytable;
}; 


