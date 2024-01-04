/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspopenpsid.h - Prototypes for the OpenPSID library
 *
 * Copyright (c) 2008 InsertWittyName (David Perry) 
 *
 */
 
module pspsdk.pspopenpsid;


extern (C) {


struct PspOpenPSID
{
	ubyte data[16];
}

int sceOpenPSIDGetOpenPSID(PspOpenPSID *openpsid);


}



