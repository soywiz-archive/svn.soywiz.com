/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspinit.h - Interface to InitForKernel.
 *
 * Copyright (c) 2007 moonlight
 *
 * $Id: pspinit.h 2345 2007-12-08 02:34:59Z raphael $
 */
module pspsdk.pspinit;

import pspsdk.pspkernel;

enum PSPBootFrom
{
	PSP_BOOT_FLASH = 0, /* ? */
	PSP_BOOT_DISC = 0x20,
	PSP_BOOT_MS = 0x40,
};

enum PSPInitApitype
{
	PSP_INIT_APITYPE_DISC = 0x120,
	PSP_INIT_APITYPE_DISC_UPDATER = 0x121,
	PSP_INIT_APITYPE_MS1 = 0x140,
	PSP_INIT_APITYPE_MS2 = 0x141,
	PSP_INIT_APITYPE_MS3 = 0x142,
	PSP_INIT_APITYPE_MS4 = 0x143,
	PSP_INIT_APITYPE_MS5 = 0x144,
	PSP_INIT_APITYPE_VSH1 = 0x210, /* ExitGame */
	PSP_INIT_APITYPE_VSH2 = 0x220, /* ExitVSH */
};

enum PSPKeyConfig
{
	PSP_INIT_KEYCONFIG_VSH = 0x100,
	PSP_INIT_KEYCONFIG_GAME = 0x200,
	PSP_INIT_KEYCONFIG_POPS = 0x300,
};

/**
 * Gets the api type 
 *
 * @returns the api type in which the system has booted
*/
extern (C) int sceKernelInitApitype();

/**
 * Gets the filename of the executable to be launched after all modules of the api.
 *
 * @returns filename of executable or NULL if no executable found.
*/
extern (C) byte *sceKernelInitFileName();

/**
 *
 * Gets the device in which the application was launched.
 *
 * @returns the device code, one of PSPBootFrom values.
*/
extern (C) int sceKernelBootFrom();

/**
 * Get the key configuration in which the system has booted.
 *
 * @returns the key configuration code, one of PSPKeyConfig values 
*/
extern (C) int InitForKernel_7233B5BC();

alias  InitForKernel_7233B5BC sceKernelInitKeyConfig;



