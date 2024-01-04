/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspusb.h - Prototypes for the sceUsb library
 *
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspusb.h 2087 2006-12-04 07:08:01Z loser $
 */
module pspsdk.pspusb;

import pspsdk.psptypes;

extern (C) {


const char[] PSP_USBBUS_DRIVERNAME = "USBBusDriver";

//Defines for use with status function return values
const int PSP_USB_ACTIVATED =              0x200;
const int PSP_USB_CABLE_CONNECTED =        0x020;
const int PSP_USB_CONNECTION_ESTABLISHED = 0x002;

/**
  * Start a USB driver.
  * 
  * @param driverName - name of the USB driver to start
  * @param size - Size of arguments to pass to USB driver start
  * @param args - Arguments to pass to USB driver start
  *
  * @return 0 on success
  */
int sceUsbStart(byte* driverName, int size, void *args);

/**
  * Stop a USB driver.
  * 
  * @param driverName - name of the USB driver to stop
  * @param size - Size of arguments to pass to USB driver start
  * @param args - Arguments to pass to USB driver start
  *
  * @return 0 on success
  */
int sceUsbStop(byte* driverName, int size, void *args);

/**
  * Activate a USB driver.
  * 
  * @param pid - Product ID for the default USB Driver
  *
  * @return 0 on success
  */
int sceUsbActivate(u32 pid);

/**
  * Deactivate USB driver.
  *
  * @param pid - Product ID for the default USB driver
  * 
  * @return 0 on success
  */
int sceUsbDeactivate(u32 pid);

/**
  * Get USB state
  * 
  * @return OR'd PSP_USB_* constants
  */
int sceUsbGetState();

/**
  * Get state of a specific USB driver
  * 
  * @param driverName - name of USB driver to get status from
  *
  * @return 1 if the driver has been started, 2 if it is stopped
  */
int sceUsbGetDrvState(byte* driverName);

/+
int sceUsbGetDrvList(u32 r4one, u32* r5ret, u32 r6one);
int sceUsbWaitState(u32 state, s32 waitmode, u32 *timeout);
int sceUsbWaitCancel();
+/


}



