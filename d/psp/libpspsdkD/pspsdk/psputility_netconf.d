/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 *  psputility_netconf.h - Definitions and Functions for Network Configuration 
 *                         section of the pspUtility library
 *
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psputility_netconf.h 2363 2008-02-16 19:40:17Z iwn $
 */
module pspsdk.psputility_netconf;

import pspsdk.psputility;
import pspsdk.psptypes;

extern (C) {

enum pspUtilityNetconfActions
{
	PSP_NETCONF_ACTION_CONNECTAP,
	PSP_NETCONF_ACTION_DISPLAYSTATUS,
	PSP_NETCONF_ACTION_CONNECT_ADHOC
};

struct pspUtilityNetconfAdhoc
{
	ubyte name[8];
	uint timeout;
}

struct _pspUtilityNetconfData
{
	pspUtilityDialogCommon base;
	int action; /** One of pspUtilityNetconfActions */
	pspUtilityNetconfAdhoc *adhocparam; //* Adhoc connection params */
	int hotspot; /** Set to 1 to allow connections with the 'Internet Browser' option set to 'Start' (ie. hotspot connection) */
	int hotspot_connected; /** Will be set to 1 when connected to a hotspot style connection */
	int wifisp; /** Set to 1 to allow connections to Wifi service providers (WISP) */
	
} 
alias _pspUtilityNetconfData pspUtilityNetconfData;

/**
 * Init the Network Configuration Dialog Utility
 *
 * @param data - pointer to pspUtilityNetconfData to be initialized
 * @return 0 on success, < 0 on error
 */
int sceUtilityNetconfInitStart (pspUtilityNetconfData *data);

/**
 * Shutdown the Network Configuration Dialog Utility
 *
 * @return 0 on success, < 0 on error
 */
int sceUtilityNetconfShutdownStart ();

/**
 * Update the Network Configuration Dialog GUI
 * 
 * @param unknown - unknown; set to 1
 * @return 0 on success, < 0 on error
 */
int sceUtilityNetconfUpdate (int unknown);

/**
 * Get the status of a running Network Configuration Dialog
 *
 * @return one of pspUtilityDialogState on success, < 0 on error
 */
int sceUtilityNetconfGetStatus ();


}



