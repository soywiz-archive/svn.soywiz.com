/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspfpu.h - Prototypes for the FPU library
 *
 * Copyright (c) 2006 TyRaNiD (James F.) 
 *
 * $Id: pspfpu.h 1782 2006-02-04 12:57:05Z tyranid $
 */
module pspsdk.pspfpu;

/* Note the bit settings in here come from an NEC MIPSv4 document,
 * they seem sensible.
 */

extern (C) {

/** Enumeration for FPU rounding modes */
enum FpuRoundMode
{
	/** Round to nearest representable value */
	FPU_RN = 0,
	/** Round towards zero */
	FPU_RZ = 1,
	/** Round towards plus infinity */
	FPU_RP = 2,
	/** Round towards minus infinity */ 
	FPU_RM = 3,
};

/** Mask value for rounding mode */
const int FPU_RM_MASK = 0x03;

/** Enumeration for FPU exceptions */
enum FpuExceptions
{
	/** Inexact operation exception */
	FPU_EXCEPTION_INEXACT   = 0x01,
	/** Underflow exception */
	FPU_EXCEPTION_UNDERFLOW = 0x02,
	/** Overflow exception */
	FPU_EXCEPTION_OVERFLOW  = 0x04,
	/** Division by zero exception */
	FPU_EXCEPTION_DIVBYZERO = 0x08,
	/** Invalid operation exception */
	FPU_EXCEPTION_INVALIDOP = 0x10,
	/** Unimplemented operation exception (only supported in the cause bits) */
	FPU_EXCEPTION_UNIMPOP   = 0x20,
	/** All exceptions */
	FPU_EXCEPTION_ALL       = 0x3F
};

/** Bit position of the flag bits */
const int FPU_FLAGS_POS = 2;
/** Bit position of the enable bits */
const int FPU_ENABLE_POS = 7;
/** Bit position of the cause bits */
const int FPU_CAUSE_POS =  12;
/** Bit position of the cc0 bit */
const int FPU_CC0_POS =   23;
/** Bit position of the fs bit */
const int FPU_FS_POS =     24;
/** Bit position of the cc1->7 bits */
const int FPU_CC17_POS =  25;

const int FPU_FLAGS_MASK = (0x1F << FPU_FLAGS_POS);
const int FPU_ENABLE_MASK = (0x1F << FPU_ENABLE_POS);
const int FPU_CAUSE_MASK = (0x3F << FPU_CAUSE_POS);
const int FPU_CC0_MASK =   (1 << FPU_CC0_POS);
const int FPU_FS_MASK =    (1 << FPU_FS_POS);
const int FPU_CC17_MASK =  (0x7F << FPU_CC17_POS);

/**
 * Get the current value of the control/status register
 *
 * @return The value of the control/status register
 */
uint pspfpu_get_fcr31();

/**
 * Set the current value of the control/status register
 *
 * @param var - The value to set.
 */
void pspfpu_set_fcr31(uint var);

/**
 * Set the current round mode
 *
 * @param mode - The rounding mode to set, one of ::FpuRoundMode
 */
void pspfpu_set_roundmode(FpuRoundMode mode);

/**
 * Get the current round mode
 *
 * @return The round mode, one of ::FpuRoundMode
 */
FpuRoundMode pspfpu_get_roundmode();

/**
 * Get the exception flags (set when an exception occurs but
 * the actual exception bit is not enabled)
 *
 * @return Bitmask of the flags, zero or more of ::FpuExceptions
 */
uint pspfpu_get_flags();

/** 
 * Clear the flags bits
 *
 * @param clear - Bitmask of the bits to clear, one or more of ::FpuExceptions
 */
void pspfpu_clear_flags(uint clear);

/**
 * Get the exception enable flags
 *
 * @return Bitmask of the flags, zero or more of ::FpuExceptions
 */
uint pspfpu_get_enable();

/** 
 * Set the enable flags bits
 *
 * @param enable - Bitmask of exceptions to enable, zero or more of ::FpuExceptions
 */
void pspfpu_set_enable(uint enable);

/**
 * Get the cause bits (only useful if you installed your own exception handler)
 *
 * @return Bitmask of flags, zero or more of ::FpuExceptions
 */
uint pspfpu_get_cause();

/**
 * Clear the cause bits
 *
 * @param clear - Bitmask of the bits to clear, one or more of ::FpuExceptions
 *
 */
void pspfpu_clear_cause(uint clear);

/**
 * Get the current value of the FS bit (if FS is 0 then an exception occurs with
 * denormalized values, if 1 then they are rewritten as 0.
 *
 * @return The current state of the FS bit (0 or 1)
 */
uint pspfpu_get_fs();

/**
 * Set the FS bit
 *
 * @param fs - 0 or 1 to unset or set fs
 */
void pspfpu_set_fs(uint fs);

/**
 * Get the condition flags (8 bits)
 *
 * @return The current condition flags
 */
uint pspfpu_get_condbits();

/**
 * Clear the condition bits
 *
 * @param clear - Bitmask of the bits to clear
 */
void pspfpu_clear_condbits(uint clear);


}



