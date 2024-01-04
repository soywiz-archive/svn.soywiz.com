/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psploadcore.h - Interface to LoadCoreForKernel.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psploadcore.h 1095 2005-09-27 21:02:16Z jim $
 */

module pspsdk.psploadcore;

public import pspsdk.pspkerneltypes;

/** @defgroup LoadCore Interface to the LoadCoreForKernel library.
 */


extern (C) {


/** @addtogroup LoadCore Interface to the LoadCoreForKernel library. */
/*@{*/

/** Describes a module.  This structure could change in future firmware revisions. */
struct SceModule {
	SceModule	*next;
	ushort		attribute;
	ubyte		version_[2];
	byte		modname[27];
	byte		terminal;
	uint		unknown1;
	uint		unknown2;
	SceUID		modid;
	uint		unknown3[4];
	void *		ent_top;
	uint		ent_size;
	void *		stub_top;
	uint		stub_size;
	uint		unknown4[4];
	uint		entry_addr;
	uint		gp_value;
	uint		text_addr;
	uint		text_size;
	uint		data_size;
	uint		bss_size;
	uint		nsegment;
	uint		segmentaddr[4];
	uint		segmentsize[4];
}

/** Defines a library and its exported functions and variables.  Use the len
    member to determine the real size of the table (size = len * 4). */
struct SceLibraryEntryTable {
	/**The library's name. */
	byte *		libname;
	/** Library version. */
	ubyte		version_[2];
	/** Library attributes. */
	ushort		attribute;
	/** Length of this entry table in 32-bit WORDs. */
	ubyte		len;
	/** The number of variables exported by the library. */
	ubyte		vstubcount;
	/** The number of functions exported by the library. */
	ushort		stubcount;
	/** Pointer to the entry table; an array of NIDs followed by
	    pointers to functions and variables. */
	void *		entrytable;
}

/** Specifies a library and a set of imports from that library.  Use the len
    member to determine the real size of the table (size = len * 4). */
struct SceLibraryStubTable {
	/* The name of the library we're importing from. */
	byte *		libname;
	/** Minimum required version of the library we want to import. */
	ubyte		version_[2];
	/* Import attributes. */
	ushort		attribute;
	/** Length of this stub table in 32-bit WORDs. */
	ubyte		len;
	/** The number of variables imported from the library. */
	ubyte		vstubcount;
	/** The number of functions imported from the library. */
	ushort		stubcount;
	/** Pointer to an array of NIDs. */
	uint *		nidtable;
	/** Pointer to the imported function stubs. */
	void *		stubtable;
	/** Pointer to the imported variable stubs. */
	void *		vstubtable;
} 


/**
 * Find a module by it's name.
 *
 * @param modname - The name of the module.
 *
 * @returns Pointer to the ::SceModule structure if found, otherwise NULL.
 */
SceModule * sceKernelFindModuleByName(byte *modname);

/**
 * Find a module from an address.
 *
 * @param addr - Address somewhere within the module.
 *
 * @returns Pointer to the ::SceModule structure if found, otherwise NULL.
 */
SceModule * sceKernelFindModuleByAddress(uint addr);

/**
 * Find a module by it's UID.
 *
 * @param modid - The UID of the module.
 *
 * @returns Pointer to the ::SceModule structure if found, otherwise NULL.
 */
SceModule * sceKernelFindModuleByUID(SceUID modid);

/**
 * Return the count of loaded modules.
 *
 * @returns The count of loaded modules.
 */
int sceKernelModuleCount();

/**
 * Invalidate the CPU's instruction cache.
 */
void sceKernelIcacheClearAll();

/*@}*/


}



