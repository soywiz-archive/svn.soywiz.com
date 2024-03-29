/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspsdk.h - Interface to the PSPSDK utility library.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: pspsdk.h 1895 2006-05-06 08:55:44Z tyranid $
 */

module pspsdk.pspsdk;

public import pspsdk.pspkerneltypes;
public import pspsdk.pspmodulemgr;
public import pspsdk.pspmoduleinfo;
public import pspsdk.pspthreadman;


extern (C) {


/** @defgroup PSPSDK PSPSDK Utility Library */

/** @addtogroup PSPSDK */
/*@{*/

/**
  * Query a modules information from its uid.
  * @note this is a replacement function for the broken kernel sceKernelQueryModuleInfo in v1.0 firmware
  * DO NOT use on a anything above that version. This also needs kernel mode access where
  * the normal one has a user mode stub.
  * 
  * @param uid - The UID of the module to query.
  * @param modinfo - Pointer a module SceKernelModuleInfo structure.
  *
  * @return < 0 on error.
  */
int pspSdkQueryModuleInfoV1(SceUID uid, SceKernelModuleInfo *modinfo);

/**
  * Get the list of module IDs.
  * @note This is a replacement function for the missing v1.5 sceKernelGetModuleIdList
  * on v1.0 firmware. DO NOT use on anything above that version.
  *
  * @param readbuf - Buffer to store the module list.
  * @param readbufsize - Number of elements in the readbuffer.
  * @param idcount - Returns the number of module ids
  *
  * @return >= 0 on success
  */
int pspSdkGetModuleIdList(SceUID *readbuf, int readbufsize, int *idcount);

/**
 * Patch the sceModuleManager module to nullify LoadDeviceCheck() calls.
 *
 * @returns 0 on success, otherwise one of ::PspKernelErrorCodes.
 *
 * @note This function must be called while running in kernel mode.  The program
 * must also be linked against the pspkernel library.
 */
int pspSdkInstallNoDeviceCheckPatch();

/**
 * Patch sceLoadCore module to remove loading plain module checks
 *
 * @note This function must be called while running in kernel mode.
 *
 * @returns 0 on success, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkInstallNoPlainModuleCheckPatch();

/**
 * Patch sceLoadModuleWithApiType to remove the kernel check in loadmodule allowing all modules to load
 *
 * @note This function must be called while running in kernel mode
 *
 * @returns 0 on success
 */
int pspSdkInstallKernelLoadModulePatch();

/**
 * Load a module and start it.
 *
 * @param filename - Path to the module.
 * @param mpid - Memory parition ID to use to load the module int.
 *
 * @returns - The UID of the module on success, otherwise one of ::PspKernelErrorCodes.
 */
SceUID pspSdkLoadStartModule(byte *filename, int mpid);

/**
 * Load a module and start it with arguments
 *
 * @param filename - Path to the module.
 * @param mpid - Memory parition ID to use to load the module int.
 * @param argc - Number of arguments to pass to start module
 * @param argv - Array of arguments
 *
 * @returns - The UID of the module on success, otherwise one of ::PspKernelErrorCodes.
 */
SceUID pspSdkLoadStartModuleWithArgs(byte *filename, int mpid, int argc, byte * argv[]);

/**
 * Manually fixup library imports for late binding modules.
 *
 * @param moduleId - Id of the module to fixup
 */
void pspSdkFixupImports(int moduleId);

/**
 * Load Inet related modules.
 * @note You must be in kernel mode to execute this function.
 *
 * @returns - 0 on success, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkLoadInetModules();

/**
 * Initialize Inet related modules.
 *
 * @returns - 0 on success, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkInetInit();

/**
 * Terminate Inet related modules.
 */
void pspSdkInetTerm();

/**
 * Search for a thread with the given name and retrieve it's ::SceKernelThreadInfo struct.
 *
 * @param name - The name of the thread to search for.
 * @param pUID - If the thread with the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the thread with the given name is found, it's ::SceKernelThreadInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferThreadStatusByName(byte *name, SceUID *pUID, SceKernelThreadInfo *pInfo);

/**
 * Search for a semaphore with the given name and retrieve it's ::SceKernelSemaInfo struct.
 *
 * @param name - The name of the sema to search for.
 * @param pUID - If the sema with the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the sema with the given name is found, it's ::SceKernelSemaInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferSemaStatusByName(byte *name, SceUID *pUID, SceKernelSemaInfo *pInfo);

/**
 * Search for an event flag with the given name and retrieve it's ::SceKernelEventFlagInfo struct.
 *
 * @param name - The name of the event flag to search for.
 * @param pUID - If the event flag with the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the event flag with the given name is found, it's ::SceKernelEventFlagInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferEventFlagStatusByName(byte *name, SceUID *pUID, SceKernelEventFlagInfo *pInfo);

/**
 * Search for a message box with the given name and retrieve it's ::SceKernelMbxInfo struct.
 *
 * @param name - The name of the message box to search for.
 * @param pUID - If the message box with the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the message box with the given name is found, it's ::SceKernelMbxInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferMboxStatusByName(byte *name, SceUID *pUID, SceKernelMbxInfo *pInfo);

/**
 * Search for a VPL with the given name and retrieve it's ::SceKernelVplInfo struct.
 *
 * @param name - The name of to search for.
 * @param pUID - If the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the given name is found, it's ::SceKernelVplInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferVplStatusByName(byte *name, SceUID *pUID, SceKernelVplInfo *pInfo);

/**
 * Search for a FPL with the given name and retrieve it's ::SceKernelFplInfo struct.
 *
 * @param name - The name of to search for.
 * @param pUID - If the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the given name is found, it's ::SceKernelFplInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferFplStatusByName(byte *name, SceUID *pUID, SceKernelFplInfo *pInfo);

/**
 * Search for a message pipe with the given name and retrieve it's ::SceKernelMppInfo struct.
 *
 * @param name - The name of to search for.
 * @param pUID - If the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the given name is found, it's ::SceKernelMppInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferMppStatusByName(byte *name, SceUID *pUID, SceKernelMppInfo *pInfo);

/**
 * Search for a callback with the given name and retrieve it's ::SceKernelCallbackInfo struct.
 *
 * @param name - The name of to search for.
 * @param pUID - If the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the given name is found, it's ::SceKernelMppInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferCallbackStatusByName(byte *name, SceUID *pUID, SceKernelCallbackInfo *pInfo);

/**
 * Search for a vtimer with the given name and retrieve it's ::SceKernelVTimerInfo struct.
 *
 * @param name - The name of to search for.
 * @param pUID - If the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the given name is found, it's ::SceKernelVTimerInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferVTimerStatusByName(byte *name, SceUID *pUID, SceKernelVTimerInfo *pInfo);

/**
 * Search for a thread event handler with the given name and retrieve it's ::SceKernelThreadEventHandlerInfo struct.
 *
 * @param name - The name of to search for.
 * @param pUID - If the given name is found, it's ::SceUID is stored here.
 * @param pInfo - If the given name is found, it's ::SceKernelThreadEventHandlerInfo data is stored here.
 *
 * @returns 0 if successful, otherwise one of ::PspKernelErrorCodes.
 */
int pspSdkReferThreadEventHandlerStatusByName(byte *name, SceUID *pUID, SceKernelThreadEventHandlerInfo *pInfo);

/**
 * Disable interrupts
 *
 * @note Do not disable interrupts for too long otherwise the watchdog will get you.
 *
 * @return The previous state of the interrupt enable bit (should be passed back to ::pspSdkEnableInterrupts)
 */
uint pspSdkDisableInterrupts();

/**
 * Enable interrupts
 *
 * @param istate - The interrupt state as returned from ::pspSdkDisableInterrupts
 */
void pspSdkEnableInterrupts(uint istate);

/**
 * Set the processors K1 register to a known value
 *
 * @note This function is for use in kernel mode syscall exports. The kernel
 * sets the k1 register to indicate what mode called the function, i.e. 
 * whether it was directly called, was called via a syscall from a kernel
 * thread or called via a syscall from a user thread. By setting k1 to 0
 * before doing anything in your code you can make the other functions think
 * you are calling from a kernel thread and therefore disable numerous 
 * protections.
 *
 * @param k1 - The k1 value to set
 * 
 * @return The previous value of k1
 */
uint pspSdkSetK1(uint k1);

/**
 * Get the current value of the processors K1 register
 *
 * @return The current value of K1
 */
uint pspSdkGetK1();

/**
 * Disable the CPUs FPU exceptions
 */
void pspSdkDisableFPUExceptions();

/*@}*/


}



