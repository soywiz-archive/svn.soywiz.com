/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psploadexec_kernel.h - Interface to LoadExecForKernel.
 *
 * Copyright (c) 2007 - DA (Taken from the 303oe SDK)
 *
 * $Id$
 */

module pspsdk.psploadexec_kernel;

public import pspsdk.pspkerneltypes;
public import pspsdk.psploadexec;
public import pspsdk.pspdconfig;

/** @defgroup LoadExecKernel Interface to the LoadExecForKernel library.
 */


extern (C) {


/** @addtogroup LoadExecKernel Interface to the LoadExecForKernel library. */
/*@{*/

/** Structure for LoadExecVSH* functions */
struct SceKernelLoadExecVSHParam {
/** Size of the structure in bytes */
    SceSize     size;
/** Size of the arguments string */
    SceSize     args;
/** Pointer to the arguments strings */
    void * argp;
/** The key, usually "game", "updater" or "vsh" */
    byte * key;
/** The size of the vshmain arguments */
    u32 vshmain_args_size;
/** vshmain arguments that will be passed to vshmain after the program has exited */
    void *vshmain_args;
/** "/kd/pspbtcnf_game.txt" or "/kd/pspbtcnf.txt" if not supplied (max. 256 chars) */
    byte *configfile;
/** An unknown string (max. 256 chars) probably used in 2nd stage of loadexec */
    u32 unk4;
/** unknown flag default value = 0x10000 */
    u32 unk5;
}

static if( _PSP_FW_VERSION < 200 ) {
/**
 * Executes a new executable from a buffer.
 *
 * @param bufsize - Size in bytes of the buffer pointed by buf.
 * @param buf - Pointer to a buffer containing the module to execute.
 * @param param - Pointer to a ::SceKernelLoadExecParam structure, or NULL.
 *
 * @returns < 0 on some errors. 
*/
int sceKernelLoadExecBufferPlain(SceSize bufsize, void *buf, SceKernelLoadExecParam *param);

} // endif

/**
 * Restart the vsh.
 *
 * @param param - Pointer to a ::SceKernelLoadExecVSHParam structure, or NULL
 *
 * @returns < 0 on some errors.
 *
 * @note - when called in game mode it will have the same effect that sceKernelExitGame
 *
*/
int sceKernelExitVSHVSH(SceKernelLoadExecVSHParam *param);

static if( _PSP_FW_VERSION >= 200 ) {
/**
 * Restart the vsh (to be used by a kernel module)
 *
 * @param param - Pointer to a ::SceKernelLoadExecVSHParam structure, or NULL
 *
 * @returns < 0 on some errors.
 *
 * @note - when called in game mode it will have the same effect that sceKernelExitGame
 * @note2: available since firmware 2.00.
*/
int sceKernelExitVSHKernel(SceKernelLoadExecVSHParam *param);

}

/**
 * Executes a new executable from a disc.
 * It is the function used by the firmware to execute the EBOOT.BIN from a disc.
 *
 * @param file - The file to execute.
 * @param param - Pointer to a ::SceKernelLoadExecVSHParam structure, or NULL.
 *
 * @returns < 0 on some errors. 
*/
int sceKernelLoadExecVSHDisc(byte *file, SceKernelLoadExecVSHParam *param);

/**
 * Executes a new executable from a disc.
 * It is the function used by the firmware to execute an updater from a disc.
 *
 * @param file - The file to execute.
 * @param param - Pointer to a ::SceKernelLoadExecVSHParam structure, or NULL.
 *
 * @returns < 0 on some errors. 
*/
int sceKernelLoadExecVSHDiscUpdater(byte *file, SceKernelLoadExecVSHParam *param);

/**
 * Executes a new executable from a memory stick.
 * It is the function used by the firmware to execute an updater from a memory stick.
 *
 * @param file - The file to execute.
 * @param param - Pointer to a ::SceKernelLoadExecVSHParam structure, or NULL.
 *
 * @returns < 0 on some errors. 
*/
int sceKernelLoadExecVSHMs1(byte *file, SceKernelLoadExecVSHParam *param);

/**
 * Executes a new executable from a memory stick.
 * It is the function used by the firmware to execute games (and homebrew :P) from a memory stick.
 *
 * @param file - The file to execute.
 * @param param - Pointer to a ::SceKernelLoadExecVSHParam structure, or NULL.
 *
 * @returns < 0 on some errors. 
*/
int sceKernelLoadExecVSHMs2(byte *file, SceKernelLoadExecVSHParam *param);

/**
 * Executes a new executable from a memory stick.
 * It is the function used by the firmware to execute ... ?
 *
 * @param file - The file to execute.
 * @param param - Pointer to a ::SceKernelLoadExecVSHParam structure, or NULL.
 *
 * @returns < 0 on some errors. 
*/
int sceKernelLoadExecVSHMs3(byte *file, SceKernelLoadExecVSHParam *param);

static if( _PSP_FW_VERSION >= 300 ) {
/***
 * Executes a new executable from a memory stick.
 * It is the function used by the firmware to execute psx games
 *
 * @param file - The file to execute.
 * @param param - Pointer to a ::SceKernelLoadExecVSHParam structure, or NULL.
 *
 * @returns < 0 on some errors. 
 * @note - Available since firmware 3.00
*/
int sceKernelLoadExecVSHMs4(byte *file, SceKernelLoadExecVSHParam *param);

}

/*@}*/

}


