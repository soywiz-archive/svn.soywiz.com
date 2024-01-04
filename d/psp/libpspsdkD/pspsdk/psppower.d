/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * psppower.h - Prototypes for the scePower library.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 * Copyright (c) 2005 John Kelley <ps2dev@kelley.ca>
 *
 * $Id: psppower.h 2209 2007-03-22 19:24:28Z jim $
 */
module pspsdk.psppower;

public import pspsdk.pspkerneltypes;


extern (C) {


/**
 * Power callback flags
 */
 /*indicates the power switch it pushed, putting the unit into suspend mode*/
const int PSP_POWER_CB_POWER_SWITCH=0x80000000;
/*indicates the hold switch is on*/
const int PSP_POWER_CB_HOLD_SWITCH=	0x40000000;
/*what is standby mode?*/
const int PSP_POWER_CB_STANDBY=		0x00080000;
/*indicates the resume process has been completed (only seems to be triggered when another event happens)*/
const int PSP_POWER_CB_RESUME_COMPLETE=	0x00040000;
/*indicates the unit is resuming from suspend mode*/
const int PSP_POWER_CB_RESUMING=		0x00020000;
/*indicates the unit is suspending, seems to occur due to inactivity*/
const int PSP_POWER_CB_SUSPENDING=		0x00010000;
/*indicates the unit is plugged into an AC outlet*/
const int PSP_POWER_CB_AC_POWER=		0x00001000;
/*indicates the battery charge level is low*/
const int PSP_POWER_CB_BATTERY_LOW=		0x00000100;
/*indicates there is a battery present in the unit*/
const int PSP_POWER_CB_BATTERY_EXIST=	0x00000080;
/*unknown*/
const int PSP_POWER_CB_BATTPOWER=		0x0000007F;

/**
 * Power Callback Function Definition
 *
 * @param unknown - unknown function, appears to cycle between 1,2 and 3
 * @param powerInfo - combination of PSP_POWER_CB_ flags
 */
typedef void (*powerCallback_t)(int unknown, int powerInfo);

/**
 * Register Power Callback Function
 *
 * @param slot - slot of the callback in the list
 * @param cbid - callback id from calling sceKernelCreateCallback
 */
int scePowerRegisterCallback(int slot, SceUID cbid);

/**
 * Check if unit is plugged in
 */
int scePowerIsPowerOnline();

/**
 * Check if a battery is present
 */
int scePowerIsBatteryExist();

/**
 * Check if the battery is charging
 */
int scePowerIsBatteryCharging();

/**
 * Get the status of the battery charging
 */
int scePowerGetBatteryChargingStatus();

/**
 * Check if the battery is low
 */
int scePowerIsLowBattery();

/**
 * Get battery life as integer percent
 * @return battery charge percentage
 */
int scePowerGetBatteryLifePercent();

/**
 * Get battery life as time
 */
int scePowerGetBatteryLifeTime();

/**
 * Get temperature of the battery
 */
int scePowerGetBatteryTemp();

/**
 * unknown? - crashes PSP in usermode
 */
int scePowerGetBatteryElec();

/**
 * Get battery volt level
 */
int scePowerGetBatteryVolt();

/**
 * Set CPU Frequency
 * @param cpufreq - new CPU frequency, valid values are 1 - 333
 */
int scePowerSetCpuClockFrequency(int cpufreq);

/**
 * Set Bus Frequency
 * @param busfreq - new BUS frequency, valid values are 1 - 167
 */
int scePowerSetBusClockFrequency(int busfreq);

/**
 * Alias for scePowerGetCpuClockFrequencyInt
 * @returns frequency as int
 */
int scePowerGetCpuClockFrequency();

/**
 * Get CPU Frequency as Integer
 * @returns frequency as int
 */
int scePowerGetCpuClockFrequencyInt();

/**
 * Get CPU Frequency as Float
 * @returns frequency as float
 */
float scePowerGetCpuClockFrequencyFloat();

/**
 * Alias for scePowerGetBusClockFrequencyInt
 * @returns frequency as int
 */
int scePowerGetBusClockFrequency();

/**
 * Get Bus fequency as Integer
 * @returns frequency as int
 */
int scePowerGetBusClockFrequencyInt();

/**
 * Get Bus frequency as Float
 * @returns frequency as float
 */
float scePowerGetBusClockFrequencyFloat();

/**
 * Set Clock Frequencies
 *
 * @param pllfreq - pll frequency, valid from 19-333
 * @param cpufreq - cpu frequency, valid from 1-333
 * @param busfreq - bus frequency, valid from 1-167
 * 
 * and:
 * 
 * cpufreq <= pllfreq
 * busfreq*2 <= pllfreq
 *
 */
int scePowerSetClockFrequency(int pllfreq, int cpufreq, int busfreq);

/**
 * Lock power switch
 *
 * Note: if the power switch is toggled while locked
 * it will fire immediately after being unlocked.
 *
 * @param unknown - pass 0
 */
int scePowerLock(int unknown);

/**
 * Unlock power switch
 *
 * @param unknown - pass 0
 */
int scePowerUnlock(int unknown);

/**
 * Generate a power tick, preventing unit from 
 * powering off and turning off display.
 *
 * @param unknown - pass 0
 */
int scePowerTick(int unknown);

/**
 * Get Idle timer
 *
 */
int scePowerGetIdleTimer();

/**
 * Enable Idle timer
 *
 * @param unknown - pass 0
 */
int scePowerIdleTimerEnable(int unknown);

/**
 * Disable Idle timer
 *
 * @param unknown - pass 0
 */
int scePowerIdleTimerDisable(int unknown);

/**
 * Request the PSP to go into standby
 *
 * @return 0 always
 */
int scePowerRequestStandby();

/**
 * Request the PSP to go into suspend
 *
 * @return 0 always
 */
int scePowerRequestSuspend();



}



