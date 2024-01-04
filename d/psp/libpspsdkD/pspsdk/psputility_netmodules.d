/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 *  psputility_netmodules.h - Load network modules from user mode on 2.xx+
 *
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psputility_netmodules.h 2002 2006-09-16 16:49:57Z jim $
 */
module pspsdk.psputility_netmodules;

// public import pspsdk.psptypes;

extern (C) {

const int PSP_NET_MODULE_COMMON = 1;
const int PSP_NET_MODULE_ADHOC = 2;
const int PSP_NET_MODULE_INET  = 3;
const int PSP_NET_MODULE_PARSEURI = 4;
const int PSP_NET_MODULE_PARSEHTTP = 5;
const int PSP_NET_MODULE_HTTP = 6;
const int PSP_NET_MODULE_SSL = 7;

/**
 * Load a network module (PRX) from user mode.
 * Load PSP_NET_MODULE_COMMON and PSP_NET_MODULE_INET
 * to use infrastructure WifI (via an access point).
 * Available on firmware 2.00 and higher only.
 *
 * @param module_ - module number to load (PSP_NET_MODULE_xxx)
 * @return 0 on success, < 0 on error
 */
int sceUtilityLoadNetModule(int module_);

/**
 * Unload a network module (PRX) from user mode.
 * Available on firmware 2.00 and higher only.
 *
 * @param module_ - module number be unloaded
 * @return 0 on success, < 0 on error
 */
int sceUtilityUnloadNetModule(int module_);


}



