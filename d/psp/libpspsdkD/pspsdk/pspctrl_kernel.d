/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspctrl_kernel.h - Prototypes for the sceCtrl_driver library.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspctrl_kernel.h 2015 2006-10-05 20:23:07Z tyranid $
 */
module pspsdk.pspctrl_kernel;

extern (C) {


/**
 * Set the controller button masks
 *
 * @param mask - The bits to setup
 * @param type - The type of operation (0 clear, 1 set mask, 2 set button)
 *
 * @par Example:
 * @code
 * sceCtrl_driver_7CA723DC(0xFFFF, 1);  // Mask lower 16bits
 * sceCtrl_driver_7CA723DC(0x10000, 2); // Always return HOME key
 * // Do something
 * sceCtrl_driver_7CA723DC(0x10000, 0); // Unset HOME key
 * sceCtrl_driver_7CA723DC(0xFFFF, 0);  // Unset mask
 * @endcode
 */
void sceCtrl_driver_7CA723DC(uint mask, uint type);

/**
 * Get button mask mode
 *
 * @mask - The bitmask to check
 *
 * @return 0 no setting, 1 set in button mask, 2 set in button set
 */
int sceCtrl_driver_5E77BC8A(uint mask);

/**
 * Setup a controller callback
 *
 * @param no - The number of the callback (0-3)
 * @param mask - The bits to check for
 * @param cb - The callback function (int curr_but, int last_but, void *arg)
 * @param arg - User defined argument passed
 *
 * @return 0 on success, < 0 on error
 */
int sceCtrl_driver_5C56C779(int no, uint mask, void (*cb)(int, int, void*), void *arg);

/* Just define some random names for the functions to make them easier to use */
alias sceCtrl_driver_7CA723DC sceCtrlSetButtonMasks ;
alias  sceCtrl_driver_5E77BC8A sceCtrlGetButtonMask;
alias  sceCtrl_driver_5C56C779 sceCtrlRegisterButtonCallback;


}

