/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 *  psputility_msdialog.h - Definitions and Functions for Dialogs
 *                         section of the pspUtility library
 *
 * Copyright (c) 2005 Marcus Comstedt <marcus@mc.pp.se>
 *			 (c) 2008 InsertWittyName <tias_dp@hotmail.com>
 *
 * $Id: psputility_msgdialog.h 2373 2008-03-23 21:06:09Z iwn $
 */
module pspsdk.psputility_msgdialog;

import pspsdk.psputility;

extern (C) {


enum pspUtilityMsgDialogMode
{
	PSP_UTILITY_MSGDIALOG_MODE_ERROR = 0, /* Error message */
	PSP_UTILITY_MSGDIALOG_MODE_TEXT /* String message */
	
};

enum pspUtilityMsgDialogOption
{
	PSP_UTILITY_MSGDIALOG_OPTION_ERROR = 0, /* Error message (why two flags?) */
	PSP_UTILITY_MSGDIALOG_OPTION_TEXT = 0x00000001, /* Text message (why two flags?) */
	PSP_UTILITY_MSGDIALOG_OPTION_YESNO_BUTTONS = 0x00000010,	/* Yes/No buttons instead of 'Cancel' */
	PSP_UTILITY_MSGDIALOG_OPTION_DEFAULT_NO  = 0x00000100	/* Default position 'No', if not set will default to 'Yes' */
};

enum pspUtilityMsgDialogPressed
{
	PSP_UTILITY_MSGDIALOG_RESULT_UNKNOWN1 = 0,
	PSP_UTILITY_MSGDIALOG_RESULT_YES,
	PSP_UTILITY_MSGDIALOG_RESULT_NO,
	PSP_UTILITY_MSGDIALOG_RESULT_BACK
	
};

/**
 * Structure to hold the parameters for a message dialog
**/
struct _SceUtilityMsgDialogParams
{
    pspUtilityDialogCommon base;
    int unknown;
	pspUtilityMsgDialogMode mode;
	uint errorValue;
    /** The message to display (may contain embedded linefeeds) */
    byte message[512];
	
	int options; /* OR ::pspUtilityMsgDialogOption together for multiple options */
	pspUtilityMsgDialogPressed buttonPressed;

} 
alias _SceUtilityMsgDialogParams pspUtilityMsgDialogParams;

/**
 * Create a message dialog
 *
 * @param params - dialog parameters
 * @returns 0 on success
 */
int sceUtilityMsgDialogInitStart(pspUtilityMsgDialogParams *params);

/**
 * Remove a message dialog currently active.  After calling this
 * function you need to keep calling GetStatus and Update until
 * you get a status of 4.
 */
void sceUtilityMsgDialogShutdownStart();

/**
 * Get the current status of a message dialog currently active.
 *
 * @return 2 if the GUI is visible (you need to call sceUtilityMsgDialogGetStatus).
 * 3 if the user cancelled the dialog, and you need to call sceUtilityMsgDialogShutdownStart.
 * 4 if the dialog has been successfully shut down.
 */
int sceUtilityMsgDialogGetStatus();

/**
 * Refresh the GUI for a message dialog currently active
 *
 * @param n - unknown, pass 1
 */
void sceUtilityMsgDialogUpdate(int n);

/**
 * Abort a message dialog currently active
 */
int sceUtilityMsgDialogAbort();


}



