/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspintrman.h - Interface to the system interrupt manager.
 *
 * Copyright (c) 2005 James F. (tyranid@gmail.com)
 * Copyright (c) 2005 Florin Sasu (...)
 *
 * $Id: pspintrman.h 1625 2005-12-29 23:16:09Z mrbrown $
 */

module pspsdk.pspintrman;

public import pspsdk.pspkerneltypes;

/** @defgroup IntrMan Interrupt Manager
  * This module contains routines to manage interrupts.
  */

/** @addtogroup IntrMan Interrupt Manager */
/*@{*/


extern (C) {


extern const byte* PspInterruptNames[67];

enum PspInterrupts
{
	PSP_GPIO_INT = 4,
	PSP_ATA_INT  = 5,
	PSP_UMD_INT  = 6,
	PSP_MSCM0_INT = 7,
	PSP_WLAN_INT  = 8,
	PSP_AUDIO_INT = 10,
	PSP_I2C_INT   = 12,
	PSP_SIRCS_INT = 14,
	PSP_SYSTIMER0_INT = 15,
	PSP_SYSTIMER1_INT = 16,
	PSP_SYSTIMER2_INT = 17,
	PSP_SYSTIMER3_INT = 18,
	PSP_THREAD0_INT   = 19,
	PSP_NAND_INT      = 20,
	PSP_DMACPLUS_INT  = 21,
	PSP_DMA0_INT      = 22,
	PSP_DMA1_INT      = 23,
	PSP_MEMLMD_INT    = 24,
	PSP_GE_INT        = 25,
	PSP_VBLANK_INT = 30,
	PSP_MECODEC_INT  = 31,
	PSP_HPREMOTE_INT = 36,
	PSP_MSCM1_INT    = 60,
	PSP_MSCM2_INT    = 61,
	PSP_THREAD1_INT  = 65,
	PSP_INTERRUPT_INT = 66
};

enum PspSubInterrupts
{
	PSP_GPIO_SUBINT = PspInterrupts.PSP_GPIO_INT,
	PSP_ATA_SUBINT  = PspInterrupts.PSP_ATA_INT,
	PSP_UMD_SUBINT  = PspInterrupts.PSP_UMD_INT,
	PSP_DMACPLUS_SUBINT = PspInterrupts.PSP_DMACPLUS_INT,
	PSP_GE_SUBINT = PspInterrupts.PSP_GE_INT,
	PSP_DISPLAY_SUBINT = PspInterrupts.PSP_VBLANK_INT
};

/**
 * Suspend all interrupts.
 *
 * @returns The current state of the interrupt controller, to be used with ::sceKernelCpuResumeIntr().
 */
uint sceKernelCpuSuspendIntr();

/**
 * Resume all interrupts.
 *
 * @param flags - The value returned from ::sceKernelCpuSuspendIntr().
 */
void sceKernelCpuResumeIntr(uint flags);

/**
 * Resume all interrupts (using sync instructions).
 *
 * @param flags - The value returned from ::sceKernelCpuSuspendIntr()
 */
void sceKernelCpuResumeIntrWithSync(uint flags);

/**
 * Determine if interrupts are suspended or active, based on the given flags.
 *
 * @param flags - The value returned from ::sceKernelCpuSuspendIntr().
 *
 * @returns 1 if flags indicate that interrupts were not suspended, 0 otherwise.
 */
int sceKernelIsCpuIntrSuspended(uint flags);

/**
 * Determine if interrupts are enabled or disabled.
 *
 * @returns 1 if interrupts are currently enabled.
 */
int sceKernelIsCpuIntrEnable();

/** 
  * Register a sub interrupt handler.
  * 
  * @param intno - The interrupt number to register.
  * @param no - The sub interrupt handler number (user controlled)
  * @param handler - The interrupt handler
  * @param arg - An argument passed to the interrupt handler
  *
  * @return < 0 on error.
  */
int sceKernelRegisterSubIntrHandler(int intno, int no, void *handler, void *arg);

/**
  * Release a sub interrupt handler.
  * 
  * @param intno - The interrupt number to register.
  * @param no - The sub interrupt handler number
  *
  * @return < 0 on error.
  */
int sceKernelReleaseSubIntrHandler(int intno, int no);

/**
  * Enable a sub interrupt.
  * 
  * @param intno - The sub interrupt to enable.
  * @param no - The sub interrupt handler number
  * 
  * @return < 0 on error.
  */
int sceKernelEnableSubIntr(int intno, int no);

/**
  * Disable a sub interrupt handler.
  *
  * @param intno - The sub interrupt to disable.
  * @param no - The sub interrupt handler number
  * 
  * @return < 0 on error.
  */
int sceKernelDisableSubIntr(int intno, int no);

struct tag_IntrHandlerOptionParam{
	int size;				//+00
	u32	entry;				//+04
	u32	common;				//+08
	u32	gp;					//+0C
	u16	intr_code;			//+10
	u16	sub_count;			//+12
	u16	intr_level;			//+14
	u16	enabled;			//+16
	u32	calls;				//+18
	u32	field_1C;			//+1C
	u32	total_clock_lo;		//+20
	u32	total_clock_hi;		//+24
	u32	min_clock_lo;		//+28
	u32	min_clock_hi;		//+2C
	u32	max_clock_lo;		//+30
	u32	max_clock_hi;		//+34
}; //=38
alias tag_IntrHandlerOptionParam PspIntrHandlerOptionParam;	

int QueryIntrHandlerInfo(SceUID intr_code, SceUID sub_intr_code, PspIntrHandlerOptionParam *data);


}


/*@}*/


