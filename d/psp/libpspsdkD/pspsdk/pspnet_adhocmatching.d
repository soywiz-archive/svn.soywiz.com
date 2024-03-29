/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspnet_adhocmatching.h - PSP Adhoc matching networking libraries.
 *
 * Copyright (c) 2006 James F.
 *
 * Based on the adhoc code in SMS Plus
 * 
 * $Id: pspnet_adhocmatching.h 2356 2008-01-15 23:50:17Z iwn $
 */
module pspsdk.pspnet_adhocmatching;


extern (C) {


const int MATCHING_JOINED = 	0x1;// Another PSP has joined
const int MATCHING_SELECTED = 	0x2;// Another PSP selected to match
const int MATCHING_REJECTED =	0x4;// The request has been rejected
const int MATCHING_CANCELED =	0x5;// The request has been cancelled
const int MATCHING_ESTABLISHED=	0x7;// Both PSP's have agreed to connect, at this point Lumines
						// closes the connection and creates a new one with just the
						// two PSP's in it.
const int MATCHING_DISCONNECT = 0xa;// A PSP has quit, this does not include when the PSP crashes

/** 
 * Initialise the Adhoc matching library
 *
 * @param unk1 - Pass 0x20000
 * 
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocMatchingInit(int unk1);       // 0x20000 in lumines

/**
 * Terminate the Adhoc matching library
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocMatchingTerm();

/** Matching callback */
typedef void (*MatchingCallback)(int unk1, int event, ubyte *mac2, int optLen, void *optData);

// returns 1 in lumines, probably an ID for matching procs
/**
 * Create an Adhoc matchine object
 *
 * @param unk1 - Pass 3
 * @param unk2 - Pass 0xA
 * @param port - Pass 0x22B
 * @param unk4 - Pass 0x800
 * @param unk5 - Pass 0x2DC6C0
 * @param unk6 - Pass 0x5B8D80
 * @param unk7 - Pass 3
 * @param unk8 - Pass 0x7A120
 * @param callback - Callback to be called on matching
 *
 * @return ID of object on success, < 0 on error.
 */
int sceNetAdhocMatchingCreate(int unk1, int unk2, int port, int unk4, int unk5, int unk6, int unk7, int unk8, MatchingCallback callback);

/**
 * Delete an Adhoc matching object
 *
 * @param matchingId - The ID returned from ::sceNetAdhocMatchingCreate
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocMatchingDelete(int matchingId);

/**
 * Start a matching object
 *
 * @param matchingId - The ID returned from ::sceNetAdhocMatchingCreate
 * @param unk1 - Pass 0x10
 * @param unk2 - Pass 0x2000
 * @param unk3 - Pass 0x10
 * @param unk4 - Pass 0x2000
 * @param usrDataSize - Size of usrData
 * @param usrData - Pointer to block of data passed to callback
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocMatchingStart(int matchingId, int unk1, int unk2, int unk3, int unk4, int usrDataSize, byte *usrData);

/** 
 * Stop a matching object
 *
 * @param matchingId - The ID returned from ::sceNetAdhocMatchingCreate
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocMatchingStop(int matchingId);

/**
 * Select a matching target
 *
 * @param matchingId - The ID returned from ::sceNetAdhocMatchingCreate
 * @param mac - MAC address to select
 * @param unk3 - Pass 0
 * @param unk4 - Pass 0
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocMatchingSelectTarget(int matchingId, ubyte *mac, int unk3, int unk4);

/**
 * Cancel a matching target
 *
 * @param matchingId - The ID returned from ::sceNetAdhocMatchingCreate
 * @param mac - The MAC address to cancel
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocMatchingCancelTarget(int matchingId, ubyte *mac);


}



