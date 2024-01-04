/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 *  psputility_netparam.h - Definitions and Functions to manage Network  
 *                          parameters.
 *
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psputility_netparam.h 2097 2006-12-10 17:16:19Z tyranid $
 */
module pspsdk.psputility_netparam;


extern (C) {


public import pspsdk.psptypes;

/**
 * Datatype for sceUtilityGetNetParam
 * since it can return a u32 or a string
 * we use a union to avoid ugly casting
 */
union netData {
	u32 asUint;
	byte asString[128];
};

const int PSP_NETPARAM_NAME =          0; // string
const int PSP_NETPARAM_SSID =         1; // string
const int PSP_NETPARAM_SECURE =       2; // int
const int PSP_NETPARAM_WEPKEY =       3; // string
const int PSP_NETPARAM_IS_STATIC_IP =  4; // int
const int PSP_NETPARAM_IP =           5; // string
const int PSP_NETPARAM_NETMASK =       6; // string
const int PSP_NETPARAM_ROUTE =        7; // string
const int PSP_NETPARAM_MANUAL_DNS =   8; // int
const int PSP_NETPARAM_PRIMARYDNS =   9; // string
const int PSP_NETPARAM_SECONDARYDNS = 10; // string
const int PSP_NETPARAM_PROXY_USER =  11; // string
const int PSP_NETPARAM_PROXY_PASS =  12; // string
const int PSP_NETPARAM_USE_PROXY =   13; // int
const int PSP_NETPARAM_PROXY_SERVER = 14; // string
const int PSP_NETPARAM_PROXY_PORT =  15; // int
const int PSP_NETPARAM_UNKNOWN1 =    16; // int
const int PSP_NETPARAM_UNKNOWN2 =    17; // int

const int PSP_NETPARAM_ERROR_BAD_NETCONF = 	0x80110601;
const int PSP_NETPARAM_ERROR_BAD_PARAM =	0x80110604;

/**
 * Check existance of a Net Configuration
 *
 * @param id - id of net Configuration (1 to n)
 * @returns 0 on success, 
 */
int sceUtilityCheckNetParam(int id);

/**
 * Get Net Configuration Parameter
 *
 * @param conf - Net Configuration number (1 to n)
 * (0 returns valid but seems to be a copy of the last config requested)
 * @param param - which parameter to get
 * @param data - parameter data
 * @returns 0 on success, 
 */
int sceUtilityGetNetParam(int conf, int param, netData *data);

/**
 * Create a new Network Configuration
 * @note This creates a new configuration at conf and clears 0
 *
 * @param conf - Net Configuration number (1 to n)
 *
 * @return 0 on success
 */
int sceUtilityCreateNetParam(int conf);

/**
 * Sets a network parameter
 * @note This sets only to configuration 0
 *
 * @param param - Which parameter to set
 * @param val - Pointer to the the data to set
 *
 * @return 0 on success
 */
int sceUtilitySetNetParam(int param, void *val);

/**
 * Copies a Network Configuration to another
 *
 * @param src - Source Net Configuration number (0 to n)
 * @param src - Destination Net Configuration number (0 to n)
 *
 * @return 0 on success
 */
int sceUtilityCopyNetParam(int src, int dest);

/**
 * Deletes a Network Configuration
 *
 * @param conf - Net Configuration number (1 to n)
 *
 * @return 0 on success
 */
int sceUtilityDeleteNetParam(int conf);


}


