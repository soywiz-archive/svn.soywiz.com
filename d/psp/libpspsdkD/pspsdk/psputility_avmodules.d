/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psputility_avmodules.h - Load audio/video modules from user mode on 2.xx+
 *
 * Copyright (c) 2007 David Perry <tias_dp@hotmail.com>
 *
 */
module pspsdk.psputility_avmodules;


extern (C) {


public import pspsdk.psptypes;

const int PSP_AV_MODULE_AVCODEC	=	0;
const int PSP_AV_MODULE_SASCORE	=	1;
const int PSP_AV_MODULE_ATRAC3PLUS =2;// Requires PSP_AV_MODULE_AVCODEC loading first
const int PSP_AV_MODULE_MPEGBASE =	3;// Requires PSP_AV_MODULE_AVCODEC loading first

/**
 * Load an audio/video module (PRX) from user mode.
 *
 * Available on firmware 2.00 and higher only.
 *
 * @param module_ - module number to load (PSP_AV_MODULE_xxx)
 * @return 0 on success, < 0 on error
 */
int sceUtilityLoadAvModule(int module_);

/**
 * Unload an audio/video module (PRX) from user mode.
 * Available on firmware 2.00 and higher only.
 *
 * @param module_ - module number to be unloaded
 * @return 0 on success, < 0 on error
 */
int sceUtilityUnloadAvModule(int module_);


}



