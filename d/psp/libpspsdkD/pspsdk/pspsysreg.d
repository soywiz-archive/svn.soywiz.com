/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspsysreg.h - Interface to sceSysreg_driver.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspsysreg.h 1095 2005-09-27 21:02:16Z jim $
 */

module pspsdk.pspsysreg;

public import pspsdk.pspkerneltypes;

/** @defgroup Sysreg Interface to the sceSysreg_driver library.
 */


extern (C) {


/** @addtogroup Sysreg Interface to the sceSysreg_driver library. */
/*@{*/

/**
  * Enable the ME reset.
  *
  * @return < 0 on error.
  */
int sceSysregMeResetEnable();

/**
  * Disable the ME reset.
  *
  * @return < 0 on error.
  */
int sceSysregMeResetDisable();

/**
  * Enable the VME reset.
  *
  * @return < 0 on error.
  */
int sceSysregVmeResetEnable();

/**
  * Disable the VME reset.
  *
  * @return < 0 on error.
  */
int sceSysregVmeResetDisable();

/**
  * Enable the ME bus clock.
  *
  * @return < 0 on error.
  */
int sceSysregMeBusClockEnable();

/**
  * Disable the ME bus clock.
  *
  * @return < 0 on error.
  */
int sceSysregMeBusClockDisable();

/*@}*/


}



