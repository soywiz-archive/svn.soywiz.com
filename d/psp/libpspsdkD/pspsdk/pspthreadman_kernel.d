/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspthreadman_kernel.h - Interface to the kernel side of threadman
 *
 * Copyright (c) 2005 James F.
 *
 * $Id: pspthreadman_kernel.h 2131 2007-01-15 21:42:22Z tyranid $
 */

module pspsdk.pspthreadman_kernel;

public import pspsdk.pspkerneltypes;
public import pspsdk.pspthreadman;
public import pspsdk.pspdconfig;

/** @defgroup ThreadmanKern Thread Manager kernel functions
  * This module contains routines to threads in the kernel
  */

/** @addtogroup ThreadmanKern Thread Manager kernel functions */
/*@{*/


extern (C) {


/**
 * Suspend all user mode threads in the system
 *
 * @return 0 on success, < 0 on error
 */
int sceKernelSuspendAllUserThreads();

/**
 * Checks if the current thread is a usermode thread
 *
 * @return 0 if kernel, 1 if user, < 0 on error
 */
int sceKernelIsUserModeThread();

/**
 * Get the user level of the current thread
 *
 * @return The user level, < 0 on error
 */
int sceKernelGetUserLevel();

/**
 * Get the return address of the current thread's syscall
 *
 * @return The RA, 0 on error
 */
uint sceKernelGetSyscallRA();

/**
 * Get the free stack space on the kernel thread
 *
 * @param thid - The UID of the thread
 *
 * @return The free stack space, < 0 on error
 */
int sceKernelGetThreadKernelStackFreeSize(SceUID thid);

/**
 * Check the thread kernel stack
 *
 * @return Unknown
 */
int sceKernelCheckThreadKernelStack();

/**
 * Extend the kernel thread stack
 *
 * @param type - The type of block allocation. One of ::PspSysMemBlockTypes
 * @param cb - A pointer to a callback function
 * @param arg - A pointer to a user specified argument
 *
 * @return < 0 on error
 */
int sceKernelExtendKernelStack(int type, void (*cb)(void*), void *arg);

/**
 * Get the system status flag
 *
 * @return The system status flag
 */
uint sceKernelGetSystemStatusFlag();

/**
 * Setup the KTLS allocator
 *
 * @param id - The ID of the allocator
 * @param cb - The allocator callback
 * @param arg - User specified arg passed to the callback
 *
 * @return < 0 on error, allocation id on success
 */
int sceKernelAllocateKTLS(int id, int (*cb)(uint *size, void *arg), void *arg);

/**
 * Free the KTLS allocator
 *
 * @param id - The allocation id returned from AllocateKTLS
 *
 * @return < 0 on error
 */
int sceKernelFreeKTLS(int id);

/**
 * Get the KTLS of the current thread
 *
 * @param id - The allocation id returned from AllocateKTLS
 * 
 * @return The current KTLS, NULL on error
 */
void *sceKernelGetKTLS(int id);

/**
 * Get the KTLS of a thread
 *
 * @param id - The allocation id returned from AllocateKTLS
 * @param thid - The thread is, 0 for current thread
 * @param mode - Perhaps? Sees to be set to 0 or 1
 *
 * @return The current KTLS, NULL on error
 */
void *sceKernelGetThreadKTLS(int id, SceUID thid, int mode);

/** Thread context
 * Structues for the thread context taken from florinsasu's post on the forums */
struct SceThreadContext {
	uint   type;
	uint   gpr[31];
	uint   fpr[32];
	uint   fc31;
	uint   hi; 
	uint   lo;
	uint   SR;
	uint   EPC;
	uint   field_114;
	uint   field_118;
} 

struct SceSCContext
{
	uint status;
	uint epc;
	uint sp;
	uint ra;
	uint k1;
	uint unk[3];
}

/** Structure to hold the status information for a thread (kernel form)
 * 1.5 form
  */
struct SceKernelThreadKInfo {
	/** Size of the structure */
	SceSize     size;
	/** Nul terminated name of the thread */
	byte    	name[32];
	/** Thread attributes */
	SceUInt     attr;
	/** Thread status */
	int     	status;
	/** Thread entry point */
	SceKernelThreadEntry    entry;
	/** Thread stack pointer */
	void *  	stack;
	/** Thread stack size */
	int     	stackSize;
	/** Kernel stack pointer */
	void *		kstack;
	/** Kernel stack size */
	void *		kstackSize;
	/** Pointer to the gp */
	void *  	gpReg;
	/** Size of args */
	SceSize     args;
	/** Pointer to args */
	void *      argp;
	/** Initial priority */
	int     	initPriority;
	/** Current priority */
	int     	currentPriority;
	/** Wait type */
	int     	waitType;
	/** Wait id */
	SceUID  	waitId;
	/** Wakeup count */
	int     	wakeupCount;
	/** Number of clock cycles run */
	SceKernelSysClock   runClocks;
static if( _PSP_FW_VERSION >= 200 ) {
	SceUInt unk3; /* Unknown extra field on later firmwares */
}
	/** Interrupt preemption count */
	SceUInt     intrPreemptCount;
	/** Thread preemption count */
	SceUInt     threadPreemptCount;
	/** Release count */
	SceUInt     releaseCount;
	/** Thread Context */
	SceThreadContext *thContext;
	/** VFPU Context */
	float *      vfpuContext;
	/** Return address from syscall */
	void  *      retAddr;
	/** Unknown, possibly size of SC context */
	SceUInt      unknown1;
	/** Syscall Context */
	SceSCContext *scContext;
}

/**
 * Refer kernel version of thread information
 *
 * @param uid - UID to find
 * @param info - Pointer to info structure, ensure size is set before calling
 *
 * @return 0 on success
 */
int ThreadManForKernel_2D69D086(SceUID uid, SceKernelThreadKInfo *info);


}


/*@}*/


