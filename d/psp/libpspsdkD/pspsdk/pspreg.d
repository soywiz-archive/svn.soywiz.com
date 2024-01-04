/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspreg.h - Prototypes for the sceReg library.
 *
 * Copyright (c) 2005 James F
 *
 * $Id: pspreg.h 2096 2006-12-10 14:19:25Z tyranid $
 */

module pspsdk.pspreg;

import pspsdk.pspkerneltypes;

extern (C) {


/** @addtogroup Reg Registry Kernel Library */
/*@{*/

/** System registry path */
const char[] SYSTEM_REGISTRY = "/system";

/** Size of a keyname, used in ::sceRegGetKeys */
const int REG_KEYNAME_SIZE = 27;

/** Key types */
enum RegKeyTypes
{
	/** Key is a directory */
	REG_TYPE_DIR = 1,
	/** Key is an integer (4 bytes) */
	REG_TYPE_INT = 2,
	/** Key is a string */
	REG_TYPE_STR = 3,
	/** Key is a binary string */
	REG_TYPE_BIN = 4,
};

/** Typedef for a registry handle */
alias uint REGHANDLE;

/** Struct used to open a registry */
struct RegParam
{
	uint regtype;     /* 0x0, set to 1 only for system */
	/** Seemingly never used, set to ::SYSTEM_REGISTRY */
	byte name[256];        /* 0x4-0x104 */
	/** Length of the name */
	uint namelen;     /* 0x104 */
	/** Unknown, set to 1 */
	uint unk2;     /* 0x108 */
	/** Unknown, set to 1 */
	uint unk3;     /* 0x10C */
}

/**
 * Open the registry
 *
 * @param reg - A filled in ::RegParam structure
 * @param mode - Open mode (set to 1)
 * @param h - Pointer to a REGHANDLE to receive the registry handle
 *
 * @return 0 on success, < 0 on error
 */
int sceRegOpenRegistry(RegParam *reg, int mode, REGHANDLE *h);

/**
 * Flush the registry to disk
 *
 * @param h - The open registry handle
 *
 * @return 0 on success, < 0 on error
 */
int sceRegFlushRegistry(REGHANDLE h);

/**
 * Close the registry 
 *
 * @param h - The open registry handle
 *
 * @return 0 on success, < 0 on error
 */
int sceRegCloseRegistry(REGHANDLE h);

/**
 * Open a registry directory
 *
 * @param h - The open registry handle
 * @param name - The path to the dir to open (e.g. /CONFIG/SYSTEM)
 * @param mode - Open mode (can be 1 or 2, probably read or read/write
 * @param hd - Pointer to a REGHANDLE to receive the registry dir handle
 *
 * @return 0 on success, < 0 on error
 */
int sceRegOpenCategory(REGHANDLE h, byte *name, int mode, REGHANDLE *hd);

/**
 * Remove a registry dir
 *
 * @param hd - The open registry dir handle
 * @param name - The name of the key
 *
 * @return 0 on success, < 0 on error
 */
int sceRegRemoveCategory(REGHANDLE h, byte *name);

/**
 * Close the registry directory
 *
 * @param hd - The open registry dir handle
 *
 * @return 0 on success, < 0 on error
 */
int sceRegCloseCategory(REGHANDLE hd);

/**
 * Flush the registry directory to disk
 *
 * @param hd - The open registry dir handle
 *
 * @return 0 on success, < 0 on error
 */
int sceRegFlushCategory(REGHANDLE hd);

/**
 * Get a key's information
 *
 * @param hd - The open registry dir handle
 * @param name - Name of the key
 * @param hk - Pointer to a REGHANDLE to get registry key handle
 * @param type - Type of the key, on of ::RegKeyTypes
 * @param size - The size of the key's value in bytes
 *
 * @return 0 on success, < 0 on error
 */
int sceRegGetKeyInfo(REGHANDLE hd, byte *name, REGHANDLE *hk, uint *type, SceSize *size);

/**
 * Get a key's information by name
 *
 * @param hd - The open registry dir handle
 * @param name - Name of the key
 * @param type - Type of the key, on of ::RegKeyTypes
 * @param size - The size of the key's value in bytes
 *
 * @return 0 on success, < 0 on error
 */
int sceRegGetKeyInfoByName(REGHANDLE hd, byte *name, uint *type, SceSize *size);

/**
 * Get a key's value
 *
 * @param hd - The open registry dir handle
 * @param hk - The open registry key handler (from ::sceRegGetKeyInfo)
 * @param buf - Buffer to hold the value
 * @param size - The size of the buffer
 *
 * @return 0 on success, < 0 on error
 */
int sceRegGetKeyValue(REGHANDLE hd, REGHANDLE hk, void *buf, SceSize size);

/**
 * Get a key's value by name
 *
 * @param hd - The open registry dir handle
 * @param name - The key name
 * @param buf - Buffer to hold the value
 * @param size - The size of the buffer
 *
 * @return 0 on success, < 0 on error
 */
int sceRegGetKeyValueByName(REGHANDLE hd, byte *name, void *buf, SceSize size);

/**
 * Set a key's value
 *
 * @param hd - The open registry dir handle
 * @param name - The key name
 * @param buf - Buffer to hold the value
 * @param size - The size of the buffer
 *
 * @return 0 on success, < 0 on error
 */
int sceRegSetKeyValue(REGHANDLE hd, byte *name, void *buf, SceSize size);

/**
 * Get number of subkeys in the current dir
 *
 * @param hd - The open registry dir handle
 * @param num - Pointer to an integer to receive the number
 *
 * @return 0 on success, < 0 on error
 */
int sceRegGetKeysNum(REGHANDLE hd, int *num);

/** 
 * Get the key names in the current directory
 *
 * @param hd - The open registry dir handle
 * @param buf - Buffer to hold the NUL terminated strings, should be num*REG_KEYNAME_SIZE
 * @param num - Number of elements in buf
 *
 * @return 0 on success, < 0 on error
 */
int sceRegGetKeys(REGHANDLE hd, byte *buf, int num);

/**
 * Create a key
 * 
 * @param hd - The open registry dir handle
 * @param name - Name of the key to create
 * @param type - Type of key (note cannot be a directory type)
 * @param size - Size of the allocated value space
 *
 * @return 0 on success, < 0 on error
 */
int sceRegCreateKey(REGHANDLE hd, byte *name, int type, SceSize size);

/**
 * Remove a registry (HONESTLY, DO NOT USE)
 *
 * @ret - Filled out registry parameter
 *
 * @return 0 on success, < 0 on error
 */
int sceRegRemoveRegistry(RegParam *reg);

/*@}*/


}



