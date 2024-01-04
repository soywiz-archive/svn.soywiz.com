/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspstdio.h - Prototypes for the sceStdio library.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspstdio.h 1095 2005-09-27 21:02:16Z jim $
 */
module pspsdk.pspstdio;

public import pspsdk.pspkerneltypes;

/** @defgroup Stdio Stdio Library 
 *  This module contains the imports for the kernel's stdio routines.
 */


extern (C) {


/** @addtogroup Stdio Stdio Library */
/*@{*/

/**
  * Function to get the current standard in file no
  * 
  * @return The stdin fileno
  */
SceUID sceKernelStdin();

/**
  * Function to get the current standard out file no
  * 
  * @return The stdout fileno
  */
SceUID sceKernelStdout();

/**
  * Function to get the current standard err file no
  * 
  * @return The stderr fileno
  */
SceUID sceKernelStderr();

/*@}*/


}



