/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspnet_apctl.h - PSP networking libraries.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@0xd6.org>
 *
 * Portions based on PspPet's wifi_03 sample code.
 * 
 * $Id: pspnet_apctl.h 1236 2005-10-27 07:31:21Z mrbrown $
 */

module pspsdk.pspnet_apctl;


extern (C) {


int sceNetApctlInit(int stackSize, int initPriority);

int sceNetApctlTerm();

int sceNetApctlGetInfo(int code, void *pInfo);

/*
// sceNetApctlAddHandler
// sceNetApctlDelHandler
*/

int sceNetApctlConnect(int connIndex);

int sceNetApctlDisconnect();

int sceNetApctlGetState(int *pState);


}



