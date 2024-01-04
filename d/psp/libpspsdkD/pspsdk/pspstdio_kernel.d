/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspstdio_kernel.h - Interface to the kernel mode library for Stdio.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspstdio_kernel.h 1095 2005-09-27 21:02:16Z jim $
 */

module pspsdk.pspstdio_kernel;

public import pspsdk.psptypes;
public import pspsdk.pspkerneltypes;
public import pspsdk.pspiofilemgr;

/** @defgroup Stdio_Kernel Driver interface to Stdio
 *  This module contains the imports for the kernel's stdio routines.
 */


extern (C) {


/** @addtogroup Stdio_Kernel Driver interface to Stdio */
/*@{*/

/** 
  * Function reopen the stdout file handle to a new file
  *
  * @param file - The file to open.
  * @param flags - The open flags 
  * @param mode - The file mode
  * 
  * @return < 0 on error.
  */
int sceKernelStdoutReopen(byte *file, int flags, SceMode mode);

/** 
  * Function reopen the stderr file handle to a new file
  *
  * @param file - The file to open.
  * @param flags - The open flags 
  * @param mode - The file mode
  * 
  * @return < 0 on error.
  */
int sceKernelStderrReopen(byte *file, int flags, SceMode mode);


/** 
  * fprintf but for file descriptors
  *
  * @param fd - file descriptor from sceIoOpen
  * @param format - format string
  * @param ... - variables
  * 
  * @return number of characters printed, <0 on error
  */
int fdprintf(int fd, byte *format, ...);
/*@}*/


}



