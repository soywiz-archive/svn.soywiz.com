/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspssl.h - Interface to the ssl library.
 *
 * Copyright (c) 2008 David Perry (InsertWittyName)
 * Copyright (c) 2008 moonlight
 *
 */

module pspsdk.pspssl;


extern (C) {


/**
 * Init the ssl library.
 *
 * @param unknown1 - Memory size? Pass 0x28000
 *
 * @returns 0 on success
*/
int sceSslInit(int unknown1);

/**
 * Terminate the ssl library.
 *
 * @returns 0 on success
*/
int sceSslEnd();

/**
 * Get the maximum memory size used by ssl.
 *
 * @param memory - Pointer where the maximum memory used value will be stored.
 *
 * @returns 0 on success
*/
int sceSslGetUsedMemoryMax(uint *memory);

/**
 * Get the current memory size used by ssl.
 *
 * @param memory - Pointer where the current memory used value will be stored.
 *
 * @returns 0 on success
*/
int sceSslGetUsedMemoryCurrent(uint *memory);


};



