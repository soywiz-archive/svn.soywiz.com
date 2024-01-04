/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspmscm.h - Memory stick utility functions
 *
 * Copyright (c) 2006 Adrahil
 *
 * $Id: pspmscm.h 2005 2006-09-17 21:36:52Z tyranid $
 */
module pspsdk.pspmscm;

import pspsdk.pspkerneltypes;
import pspsdk.pspiofilemgr;

extern (C) {


/**
 * Returns whether a memory stick is current inserted
 *
 * @return 1 if memory stick inserted, 0 if not or if < 0 on error
 */
static int MScmIsMediumInserted()
{
	int status, ret;

	ret = sceIoDevctl(cast(byte*)"mscmhc0:", 0x02025806, null, 0, &status, status.sizeof);
	if(ret < 0) return ret;
	if(status != 1) return 0;

	return 1;
}

/* Event which has occurred in the memory stick ejection callback, passed in arg2 */
const int MS_CB_EVENT_INSERTED = 1;
const int MS_CB_EVENT_EJECTED  = 2;

/**
 * Registers a memory stick ejection callback
 *
 * @param cbid - The uid of an allocated callback
 *
 * @return 0 on success, < 0 on error
 */
static int MScmRegisterMSInsertEjectCallback(SceUID cbid)
{
	return sceIoDevctl(cast(byte*)"fatms0:", 0x02415821, &cbid, cbid.sizeof, null, 0);
}

/**
 * Unregister a memory stick ejection callback
 *
 * @param cbid - The uid of an allocated callback
 *
 * @return 0 on success, < 0 on error
 */
static int MScmUnregisterMSInsertEjectCallback(SceUID cbid)
{
	return sceIoDevctl(cast(byte*)"fatms0:", 0x02415822, &cbid, cbid.sizeof, null, 0);
}


}



