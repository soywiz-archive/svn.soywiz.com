/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspnand_driver.h - Definitions and interfaces to the NAND (flash) driver.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@0xd6.org>
 *
 * $Id: pspnand_driver.h 1211 2005-10-24 06:36:00Z mrbrown $
 */

module pspsdk.pspnand_driver;

public import pspsdk.pspkerneltypes;


extern (C) {


int sceNandSetWriteProtect(int protectFlag);

int sceNandLock(int writeFlag);

void sceNandUnlock();

int sceNandReadStatus();

int sceNandReset(int flag);

int sceNandReadId(void *buf, SceSize size);

int sceNandReadPages(u32 ppn, void *buf, void *buf2, u32 count);

/*
// sceNandWritePages
// sceNandReadAccess
// sceNandWriteAccess
// sceNandEraseBlock
// sceNandReadExtraOnly
// sceNandCalcEcc
// sceNandVerifyEcc
// sceNandCollectEcc
*/

int sceNandGetPageSize();

int sceNandGetPagesPerBlock();

int sceNandGetTotalBlocks();

/*
// sceNandWriteBlock
// sceNandWriteBlockWithVerify
*/

int sceNandReadBlockWithRetry(u32 ppn, void *buf, void *buf2);

/*
// sceNandVerifyBlockWithRetry
// sceNandEraseBlockWithRetry
*/

int sceNandIsBadBlock(u32 ppn);

/*
// sceNandEraseAllBlock
// sceNandTestBlock
*/


}



