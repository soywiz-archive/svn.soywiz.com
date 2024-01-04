/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 *  psputility.h - Master include for the pspUtility library
 *
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psputility.h 2387 2008-05-04 17:15:32Z iwn $
 */
module pspsdk.psputility;

struct pspUtilityDialogCommon
{
	uint size;			/** Size of the structure */
	int language;		/** Language */
	int buttonSwap;		/** Set to 1 for X/O button swap */
	int graphicsThread;	/** Graphics thread priority */
	int accessThread;	/** Access/fileio thread priority (SceJobThread) */
	int fontThread;		/** Font thread priority (ScePafThread) */
	int soundThread;	/** Sound thread priority */
	int result;			/** Result */
	int reserved[4];	/** Set to 0 */

}

//public import pspsdk.psputility_msgdialog;
//public import pspsdk.psputility_netconf;
public import pspsdk.psputility_netparam;
//public import pspsdk.psputility_savedata;
//public import pspsdk.psputility_gamesharing;
//public import pspsdk.psputility_htmlviewer;
public import pspsdk.psputility_sysparam;
//public import pspsdk.psputility_osk;
public import pspsdk.psputility_netmodules;
public import pspsdk.psputility_avmodules;
public import pspsdk.psputility_usbmodules;
public import pspsdk.psputility_modules;

const int PSP_UTILITY_ACCEPT_CIRCLE = 0;
const int PSP_UTILITY_ACCEPT_CROSS =  1;

/**
 * Return-values for the various sceUtility***GetStatus() functions
**/
enum pspUtilityDialogState
{
	PSP_UTILITY_DIALOG_NONE = 0,	/**< No dialog is currently active */
	PSP_UTILITY_DIALOG_INIT,		/**< The dialog is currently being initialized */
	PSP_UTILITY_DIALOG_VISIBLE,		/**< The dialog is visible and ready for use */
	PSP_UTILITY_DIALOG_QUIT,		/**< The dialog has been canceled and should be shut down */
	PSP_UTILITY_DIALOG_FINISHED		/**< The dialog has successfully shut down */
	
};


