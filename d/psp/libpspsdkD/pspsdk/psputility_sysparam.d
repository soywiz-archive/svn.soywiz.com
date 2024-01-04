/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 *  psputility_sysparam.h - Definitions and Functions for System Paramters 
 *                          section of the pspUtility library
 *
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psputility_sysparam.h 2266 2007-07-03 15:22:07Z oopo $
 */
module pspsdk.psputility_sysparam;


extern (C) {


public import pspsdk.psptypes;

/**
 * IDs for use inSystemParam functions
 * PSP_SYSTEMPARAM_ID_INT are for use with SystemParamInt funcs
 * PSP_SYSTEMPARAM_ID_STRING are for use with SystemParamString funcs
 */
const int PSP_SYSTEMPARAM_ID_STRING_NICKNAME =	1;
const int PSP_SYSTEMPARAM_ID_INT_ADHOC_CHANNEL =2;
const int PSP_SYSTEMPARAM_ID_INT_WLAN_POWERSAVE=3;
const int PSP_SYSTEMPARAM_ID_INT_DATE_FORMAT =	4;
const int PSP_SYSTEMPARAM_ID_INT_TIME_FORMAT =	5;
//Timezone offset from UTC in minutes, (EST = -300 = -5 * 60)
const int PSP_SYSTEMPARAM_ID_INT_TIMEZONE =		6;
const int PSP_SYSTEMPARAM_ID_INT_DAYLIGHTSAVINGS=7;
const int PSP_SYSTEMPARAM_ID_INT_LANGUAGE =		8;
/**
 * #9 seems to be Region or maybe X/O button swap.
 * It doesn't exist on JAP v1.0
 * is 1 on NA v1.5s
 * is 0 on JAP v1.5s
 * is read-only
 */
const int PSP_SYSTEMPARAM_ID_INT_UNKNOWN =		9;

/**
 * Return values for the SystemParam functions
 */
const int PSP_SYSTEMPARAM_RETVAL_OK =	0;
const int PSP_SYSTEMPARAM_RETVAL_FAIL =	0x80110103;

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_ADHOC_CHANNEL
 */
const int PSP_SYSTEMPARAM_ADHOC_CHANNEL_AUTOMATIC= 0;
const int PSP_SYSTEMPARAM_ADHOC_CHANNEL_1 =		1;
const int PSP_SYSTEMPARAM_ADHOC_CHANNEL_6 =		6;
const int PSP_SYSTEMPARAM_ADHOC_CHANNEL_11 =	11;

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_WLAN_POWERSAVE
 */
const int PSP_SYSTEMPARAM_WLAN_POWERSAVE_OFF =	0;
const int PSP_SYSTEMPARAM_WLAN_POWERSAVE_ON	= 	1;

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_DATE_FORMAT
 */
const int PSP_SYSTEMPARAM_DATE_FORMAT_YYYYMMDD =	0;
const int PSP_SYSTEMPARAM_DATE_FORMAT_MMDDYYYY =	1;
const int PSP_SYSTEMPARAM_DATE_FORMAT_DDMMYYYY =	2;

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_TIME_FORMAT
 */
const int PSP_SYSTEMPARAM_TIME_FORMAT_24HR =0;
const int PSP_SYSTEMPARAM_TIME_FORMAT_12HR =1;

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_DAYLIGHTSAVINGS
 */
const int PSP_SYSTEMPARAM_DAYLIGHTSAVINGS_STD =		0;
const int PSP_SYSTEMPARAM_DAYLIGHTSAVINGS_SAVING =	1;

/**
 * Valid values for PSP_SYSTEMPARAM_ID_INT_LANGUAGE
 */
const int PSP_SYSTEMPARAM_LANGUAGE_JAPANESE	=		0;
const int PSP_SYSTEMPARAM_LANGUAGE_ENGLISH =		1;
const int PSP_SYSTEMPARAM_LANGUAGE_FRENCH =			2;
const int PSP_SYSTEMPARAM_LANGUAGE_SPANISH	=		3;
const int PSP_SYSTEMPARAM_LANGUAGE_GERMAN =			4;
const int PSP_SYSTEMPARAM_LANGUAGE_ITALIAN =		5;
const int PSP_SYSTEMPARAM_LANGUAGE_DUTCH =			6;
const int PSP_SYSTEMPARAM_LANGUAGE_PORTUGUESE =		7;
const int PSP_SYSTEMPARAM_LANGUAGE_RUSSIAN =		8;
const int PSP_SYSTEMPARAM_LANGUAGE_KOREAN =			9;
const int PSP_SYSTEMPARAM_LANGUAGE_CHINESE_TRADITIONAL=	10;
const int PSP_SYSTEMPARAM_LANGUAGE_CHINESE_SIMPLIFIED=	11;

/**
 * Set Integer System Parameter
 *
 * @param id - which parameter to set
 * @param value - integer value to set
 * @returns 0 on success, PSP_SYSTEMPARAM_RETVAL_FAIL on failure
 */
int sceUtilitySetSystemParamInt(int id, int value);

/**
 * Set String System Parameter
 *
 * @param id - which parameter to set
 * @param str - char * value to set
 * @returns 0 on success, PSP_SYSTEMPARAM_RETVAL_FAIL on failure
 */
int sceUtilitySetSystemParamString(int id, byte *str);

/**
 * Get Integer System Parameter
 *
 * @param id - which parameter to get
 * @param value - pointer to integer value to place result in
 * @returns 0 on success, PSP_SYSTEMPARAM_RETVAL_FAIL on failure
 */
int sceUtilityGetSystemParamInt( int id, int *value );

/**
 * Get String System Parameter
 *
 * @param id - which parameter to get
 * @param str - char * buffer to place result in
 * @param len - length of str buffer
 * @returns 0 on success, PSP_SYSTEMPARAM_RETVAL_FAIL on failure
 */
int sceUtilityGetSystemParamString(int id, byte *str, int len);


}



