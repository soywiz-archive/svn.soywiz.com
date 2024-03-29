/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psputilsforkernel.h - Include file for UtilsForKernel
 *
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 * Copyright (c) 2005 adresd
 *
 * $Id: psputilsforkernel.h 2339 2007-12-06 19:41:18Z raphael $
 */

module pspsdk.psputilsforkernel;

import pspsdk.psptypes;

extern (C) {


/**
 * Decompress gzip'd data (requires kernel mode)
 *
 * @param dest - pointer to destination buffer
 * @param destSize - size of destination buffer
 * @param src - pointer to source (compressed) data
 * @param unknown - unknown, pass NULL
 * @return size decompressed on success, < 0 on error
 */
int sceKernelGzipDecompress(u8 *dest, u32 destSize, u8 *src, u32 unknown);

/**
 * Decompress deflate'd data (requires kernel mode)
 *
 * @param dest - pointer to destination buffer
 * @param destSize - size of destination buffer
 * @param src - pointer to source (compressed) data
 * @param unknown - unknown, pass NULL
 * @return size decompressed on success, < 0 on error
 */
int sceKernelDeflateDecompress(u8 *dest, u32 destSize, u8 *src, u32 unknown);

/**
 * Invalidate the entire data cache
 */ 
void sceKernelDcacheInvalidateAll();

/**
 * Check whether the specified address is in the data cache
 * @param addr - The address to check
 *
 * @return 0 = not cached, 1 = cache
 */
int  sceKernelDcacheProbe(void *addr);

/**
 * Invalidate the entire instruction cache
 */
void sceKernelIcacheInvalidateAll();

/**
 * Invalidate a instruction cache range.
 * @param addr - The start address of the range.
 * @param size - The size in bytes
 */
void sceKernelIcacheInvalidateRange(void *addr, uint size);

/**
 * Check whether the specified address is in the instruction cache
 * @param addr - The address to check
 *
 * @return 0 = not cached, 1 = cache
 */
int  sceKernelIcacheProbe(void *addr);


}



