/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspmodulemgr.h - Prototypes to manage manage modules.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 * Copyright (c) 2005 Matthew H <matthewh@webone.com.au>
 *
 * $$
 */
module pspsdk.pspsircs;

import pspsdk.psptypes;

/** @defgroup Sony Integrated Remote Control System Library
  * This module contains the imports for the kernel's remote control routines.
  */


extern (C) {


/** @addtogroup Sony Integrated Remote Control System Library */
/*@{*/

struct sircs_data {
	u8 type; // 12, 15 or 20 bits
	u8 cmd;  // 7 bit cmd
	u16 dev; // 5, 8 or 13 bit device address
} //  __packed__; ???

/**
  */
int sceSircsSend(sircs_data* sd, int count); 

/*@}*/


}



