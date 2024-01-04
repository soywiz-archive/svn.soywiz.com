/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psputility_modules.h - Load modules from user mode
 *
 * Copyright (c) 2008 David Perry <tias_dp@hotmail.com>
 *
 */
module pspsdk.psputility_modules;


extern (C) {


public import pspsdk.psptypes;

/* Net Modules */
const int PSP_MODULE_NET_COMMON	=		0x0100;
const int PSP_MODULE_NET_ADHOC =		0x0101;
const int PSP_MODULE_NET_INET =			0x0102;
const int PSP_MODULE_NET_PARSEURI =		0x0103;
const int PSP_MODULE_NET_PARSEHTTP =	0x0104;
const int PSP_MODULE_NET_HTTP =			0x0105;
const int PSP_MODULE_NET_SSL =			0x0106;

/* USB Modules */
const int PSP_MODULE_USB_PSPCM =		0x0200;
const int PSP_MODULE_USB_MIC =			0x0201;
const int PSP_MODULE_USB_CAM =			0x0202;
const int PSP_MODULE_USB_GPS =			0x0203;

/* Audio/video Modules */
const int PSP_MODULE_AV_AVCODEC =		0x0300;
const int PSP_MODULE_AV_SASCORE	=		0x0301;
const int PSP_MODULE_AV_ATRAC3PLUS =	0x0302;
const int PSP_MODULE_AV_MPEGBASE =		0x0303;
const int PSP_MODULE_AV_MP3	=			0x0304;

/**
 * Load a module (PRX) from user mode.
 *
 * @param module_ - module to load (PSP_MODULE_xxx)
 *
 * @return 0 on success, < 0 on error
 */
int sceUtilityLoadModule(int module_);

/**
 * Unload a module (PRX) from user mode.
 *
 * @param module_ - module to unload (PSP_MODULE_xxx)
 *
 * @return 0 on success, < 0 on error
 */
int sceUtilityUnloadModule(int module_);


}



