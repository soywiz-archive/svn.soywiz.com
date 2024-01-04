/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspwlan.h - Prototypes for the sceWlan library
 *
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspwlan.h 2207 2007-03-16 16:42:08Z tyranid $
 */
module pspsdk.pspwlan;

import pspsdk.psptypes;

extern (C) {


/**
 * Determine if the wlan device is currently powered on
 *
 * @return 0 if off, 1 if on
 */
int sceWlanDevIsPowerOn();

/**
 * Determine the state of the Wlan power switch
 *
 * @return 0 if off, 1 if on
 */
int sceWlanGetSwitchState();

/**
 * Get the Ethernet Address of the wlan controller
 *
 * @param etherAddr - pointer to a buffer of u8 (NOTE: it only writes to 6 bytes, but 
 * requests 8 so pass it 8 bytes just in case)
 * @return 0 on success, < 0 on error
 */
int sceWlanGetEtherAddr(u8 *etherAddr);

/**
 * Attach to the wlan device
 *
 * @return 0 on success, < 0 on error.
 */
int sceWlanDevAttach();

/**
 * Detach from the wlan device
 *
 * @return 0 on success, < 0 on error/
 */
int sceWlanDevDetach();

/*
int sceWlanGPBindRegError();
*/


}



