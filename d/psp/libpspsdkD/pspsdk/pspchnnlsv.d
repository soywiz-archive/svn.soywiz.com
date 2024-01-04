/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 *  pspchnnlsv.h - Include for the pspChnnlsv library.
 *
 * Copyright (c) 2005 Jim Paris <jim@jtan.com>
 * Copyright (c) 2005 psp123
 *
 * $Id: pspchnnlsv.h 1559 2005-12-10 01:10:11Z jim $
 */
module pspsdk.pspchnnlsv;

/* The descriptions are mostly speculation. */

/** @defgroup Chnnlsv Chnnlsv Library
  * Library imports for the vsh chnnlsv library.
  */


extern (C) {


import pspsdk.psptypes;

/** @addtogroup Chnnlsv Chnnlsv Library */
/*@{*/

struct _pspChnnlsvContext1 {
	/** Cipher mode */
	int	mode;

	/** Context data */
	byte	buffer1[0x10];
	byte    buffer2[0x10];
	int	unknown;
};
alias _pspChnnlsvContext1 pspChnnlsvContext1;

struct _pspChnnlsvContext2 {
	/** Context data */
	byte    unknown[0x100];
};
alias _pspChnnlsvContext2 pspChnnlsvContext2;

/**
 * Initialize context
 *
 * @param ctx - Context
 * @param mode - Cipher mode
 * @returns < 0 on error
 */
int sceChnnlsv_E7833020(pspChnnlsvContext1 *ctx, int mode);
	
/**
 * Process data
 *
 * @param ctx - Context
 * @param data - Data (aligned to 0x10)
 * @param len - Length (aligned to 0x10)
 * @returns < 0 on error
 */
int sceChnnlsv_F21A1FCA(pspChnnlsvContext1 *ctx, ubyte *data, int len);

/**
 * Finalize hash
 *
 * @param ctx - Context
 * @param hash - Hash output (aligned to 0x10, 0x10 bytes long)
 * @param cryptkey - Crypt key or NULL.
 * @returns < 0 on error
 */
int sceChnnlsv_C4C494F8(pspChnnlsvContext1 *ctx, ubyte *hash, ubyte *cryptkey);

/**
 * Prepare a key, and set up integrity check
 *
 * @param ctx - Context
 * @param mode1 - Cipher mode
 * @param mode2 - Encrypt mode (1 = encrypting, 2 = decrypting)
 * @param hashkey - Key out
 * @param cipherkey - Key in
 * @returns < 0 on error
 */
int sceChnnlsv_ABFDFC8B(pspChnnlsvContext2 *ctx, int mode1, int mode2,
			ubyte *hashkey, ubyte *cipherkey);

/**
 * Process data for integrity check
 *
 * @param ctx - Context
 * @param data - Data (aligned to 0x10)
 * @param len - Length (aligned to 0x10)
 * @returns < 0 on error
 */
int sceChnnlsv_850A7FA1(pspChnnlsvContext2 *ctx, ubyte *data, int len);

/**
 * Check integrity
 *
 * @param ctx - Context
 * @returns < 0 on error
 */
int sceChnnlsv_21BE78B4(pspChnnlsvContext2 *ctx);

/*@}*/


}




