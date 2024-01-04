/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 *  psputility_savedata.h - Definitions and Functions for savedata part of
 *                     pspUtility library
 *
 * Copyright (c) 2005    Shine
 *                       weltall <weltall@consoleworld.org>
 *                       Marcus R. Brown <mrbrown@ocgnet.org>
 *						 InsertWittyName <tias_dp@hotmail.com>
 *
 * $Id: psputility_savedata.h 2353 2008-01-07 23:58:44Z iwn $
 */

module pspsdk.psputility_savedata;

import pspsdk.psptypes;
import pspsdk.pspkerneltypes;
import pspsdk.pspdconfig;
import pspsdk.psputility;

extern (C) {


/** Save data utility modes */
enum PspUtilitySavedataMode
{
	PSP_UTILITY_SAVEDATA_AUTOLOAD = 0,
	PSP_UTILITY_SAVEDATA_AUTOSAVE,
	PSP_UTILITY_SAVEDATA_LOAD,
	PSP_UTILITY_SAVEDATA_SAVE,
	PSP_UTILITY_SAVEDATA_LISTLOAD,
	PSP_UTILITY_SAVEDATA_LISTSAVE,
	PSP_UTILITY_SAVEDATA_LISTDELETE,
	PSP_UTILITY_SAVEDATADELETE,

};

/** Initial focus position for list selection types */
enum PspUtilitySavedataFocus
{
	PSP_UTILITY_SAVEDATA_FOCUS_UNKNOWN = 0,
	PSP_UTILITY_SAVEDATA_FOCUS_FIRSTLIST,	/* First in list */
	PSP_UTILITY_SAVEDATA_FOCUS_LASTLIST,	/* Last in list */
	PSP_UTILITY_SAVEDATA_FOCUS_LATEST,	/* Most recent date */
	PSP_UTILITY_SAVEDATA_FOCUS_OLDEST,	/* Oldest date */
	PSP_UTILITY_SAVEDATA_FOCUS_UNKNOWN2,
	PSP_UTILITY_SAVEDATA_FOCUS_UNKNOWN3,
	PSP_UTILITY_SAVEDATA_FOCUS_FIRSTEMPTY, /* First empty slot */
	PSP_UTILITY_SAVEDATA_FOCUS_LASTEMPTY,	/*Last empty slot */
	
};


/** title, savedataTitle, detail: parts of the unencrypted SFO
    data, it contains what the VSH and standard load screen shows */
struct PspUtilitySavedataSFOParam
{
	byte title[0x80];
	byte savedataTitle[0x80];
	byte detail[0x400];
	ubyte parentalLevel;
	ubyte unknown[3];
}

struct PspUtilitySavedataFileData {
	void *buf;
	SceSize bufSize;
	SceSize size;	/* ??? - why are there two sizes? */
	int unknown;	
}

struct PspUtilitySavedataListSaveNewData
{
	PspUtilitySavedataFileData icon0;
	byte *title;	
}

/** Structure to hold the parameters for the ::sceUtilitySavedataInitStart function. */
struct SceUtilitySavedataParam
{
	pspUtilityDialogCommon base;

	PspUtilitySavedataMode mode;
	
	int unknown1;
	
	int overwrite;

	/** gameName: name used from the game for saves, equal for all saves */
	byte gameName[13];
	byte reserved[3];
	/** saveName: name of the particular save, normally a number */
	byte saveName[20];

	/** saveNameList: used by multiple modes */
	byte (*saveNameList)[20];

	/** fileName: name of the data file of the game for example DATA.BIN */
	byte fileName[13];
	byte reserved1[3];

	/** pointer to a buffer that will contain data file unencrypted data */
	void *dataBuf;
	/** size of allocated space to dataBuf */
	SceSize dataBufSize;
	SceSize dataSize;

	PspUtilitySavedataSFOParam sfoParam;

	PspUtilitySavedataFileData icon0FileData;
	PspUtilitySavedataFileData icon1FileData;
	PspUtilitySavedataFileData pic1FileData;
	PspUtilitySavedataFileData snd0FileData;

	/** Pointer to an PspUtilitySavedataListSaveNewData structure */
	PspUtilitySavedataListSaveNewData *newData;

	/** Initial focus for lists */
	PspUtilitySavedataFocus focus;

	/** unknown2: ? */
	int unknown2[4];

static if( _PSP_FW_VERSION >= 200 ) {

	/** key: encrypt/decrypt key for save with firmware >= 2.00 */
	byte key[16];

	/** unknown3: ? */
	byte unknown3[20];

}

}


/**
 * Saves or Load savedata to/from the passed structure
 * After having called this continue calling sceUtilitySavedataGetStatus to
 * check if the operation is completed
 *
 * @param params - savedata parameters
 * @returns 0 on success
 */
int sceUtilitySavedataInitStart(SceUtilitySavedataParam * params);

/**
 * Check the current status of the saving/loading/shutdown process
 * Continue calling this to check current status of the process
 * before calling this call also sceUtilitySavedataUpdate
 * @returns 2 if the process is still being processed.
 * 3 on save/load success, then you can call sceUtilitySavedataShutdownStart.
 * 4 on complete shutdown.
 */
int sceUtilitySavedataGetStatus();


/**
 * Shutdown the savedata utility. after calling this continue calling
 * ::sceUtilitySavedataGetStatus to check when it has shutdown
 *
 * @return 0 on success
 *
 */
int sceUtilitySavedataShutdownStart();

/**
 * Refresh status of the savedata function
 *
 * @param unknown - unknown, pass 1
 */
void sceUtilitySavedataUpdate(int unknown);


}



