/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psputility_usbmodules.h - Load usb modules from user mode on 2.70 and higher
 *
 * Copyright (c) 2007 David Perry <tias_dp@hotmail.com>
 *
 */
module pspsdk.psputility_usbmodules;


extern (C) {


public import pspsdk.psptypes;

const int PSP_USB_MODULE_PSPCM=	1;
const int PSP_USB_MODULE_ACC=	2;
const int PSP_USB_MODULE_MIC=	3;// Requires PSP_USB_MODULE_ACC loading first
const int PSP_USB_MODULE_CAM=	4;// Requires PSP_USB_MODULE_ACC loading first
const int PSP_USB_MODULE_GPS=	5;// Requires PSP_USB_MODULE_ACC loading first

/**
 * Load a usb module (PRX) from user mode.
 * Available on firmware 2.70 and higher only.
 *
 * @param module_ - module number to load (PSP_USB_MODULE_xxx)
 * @return 0 on success, < 0 on error
*/
int sceUtilityLoadUsbModule(int module_);

/**
 * Unload a usb module (PRX) from user mode.
 * Available on firmware 2.70 and higher only.
 *
 * @param module_ - module number to be unloaded
 * @return 0 on success, < 0 on error
*/
int sceUtilityUnloadUsbModule(int module_);


}



