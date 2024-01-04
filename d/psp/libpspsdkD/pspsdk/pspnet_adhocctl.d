/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspnet_adhocctl.h - PSP Adhoc control networking libraries.
 *
 * Copyright (c) 2006 James F.
 * Copyright (c) 2008 InsertWittyName <tias_dp@hotmail.com>
 *
 * Based on the adhoc code in SMS Plus
 * 
 * $Id: pspnet_adhocctl.h 2372 2008-03-23 20:50:32Z iwn $
 */
module pspsdk.pspnet_adhocctl;


extern (C) {


/** Product structure */
struct productStruct
{
	/** Unknown, set to 0 */
	int unknown;
	/** The product ID string */
	byte product[9];
}

/** Peer info structure */
struct SceNetAdhocctlPeerInfo
{
	SceNetAdhocctlPeerInfo *next;
	/** Nickname */
	byte nickname[128];	
	/** Mac address */
	ubyte mac[6];
	/** Unknown */
	ubyte unknown[6];
	/** Time stamp */
	uint timestamp;
}

/** Scan info structure */
struct SceNetAdhocctlScanInfo
{
	SceNetAdhocctlScanInfo *next;
	/** Channel number */
	int channel;
	/** Name (alphanumeric chanracters only) */
	byte name[8];
	/** The BSSID */
	ubyte bssid[6];
	/** Unknown */
	ubyte unknown[2];
	/** Unknown */
	int unknown2;
}

/**
 * Initialise the Adhoc control library
 *
 * @param unk1 - Set to 0x2000
 * @param unk2 - Set to 0x30
 * @param product - Pass a filled in ::productStruct
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocctlInit(int unk1, int unk2, productStruct *product);

/**
 * Terminate the Adhoc control library
 *
 * @return 0 on success, < on error.
 */
int sceNetAdhocctlTerm();

/**
 * Connect to the Adhoc control
 *
 * @param unk1 - Pass ""
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlConnect(byte *unk1);

/**
 * Disconnect from the Adhoc control
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocctlDisconnect();

/**
 * Get the state of the Adhoc control
 *
 * @param event - Pointer to an integer to receive the status. Can continue when it becomes 1.
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocctlGetState(int *event);

/**
 * Connect to the Adhoc control (as a host)
 *
 * @param name - The name of the connection (maximum 8 alphanumeric characters).
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlCreate(byte *name);

/**
 * Connect to the Adhoc control (as a client)
 *
 * @param scaninfo - A valid ::SceNetAdhocctlScanInfo struct that has been filled by sceNetAchocctlGetScanInfo
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlJoin(SceNetAdhocctlScanInfo *scaninfo);

/**
 * Connect to the Adhoc control game mode (as a host)
 *
 * @param name - The name of the connection (maximum 8 alphanumeric characters).
 * @param unknown - Pass 1.
 * @param num - The total number of players (including the host).
 * @param macs - A pointer to a list of the participating mac addresses, host first, then clients.
 * @param timeout - Timeout in microseconds.
 * @param unknown2 - pass 0.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlCreateEnterGameMode(byte *name, int unknown, int num, ubyte *macs, uint timeout, int unknown2);

/**
 * Connect to the Adhoc control game mode (as a client)
 *
 * @param name - The name of the connection (maximum 8 alphanumeric characters).
 * @param host - The mac address of the host.
 * @param timeout - Timeout in microseconds.
 * @param unknown - pass 0.
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlJoinEnterGameMode(byte *name, ubyte *hostmac, uint timeout, int unknown);

/**
 * Get a list of peers
 *
 * @param length - The length of the list.
 * @param host - An allocated area of size length.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlGetPeerList(int *length, void *buf);

/**
 * Get peer information
 *
 * @param mac - The mac address of the peer.
 * @param size - Size of peerinfo.
 * @param peerinfo - Pointer to store the information.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlGetPeerInfo(ubyte *mac, int size, SceNetAdhocctlPeerInfo *peerinfo);

/**
 * Scan the adhoc channels
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlScan();

/**
 * Get the results of a scan
 *
 * @param length - The length of the list.
 * @param host - An allocated area of size length.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlGetScanInfo(int *length, void *buf);

typedef void (*sceNetAdhocctlHandler)(int flag, int error, void *unknown);

/**
 * Register an adhoc event handler
 *
 * @param handler - The event handler.
 * @param unknown - Pass NULL.
 *
 * @return Handler id on success, < 0 on error.
 */
int sceNetAdhocctlAddHandler(sceNetAdhocctlHandler handler, void *unknown);

/**
 * Delete an adhoc event handler
 *
 * @param id - The handler id as returned by sceNetAdhocctlAddHandler.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlDelHandler(int id);

/**
 * Get nickname from a mac address
 *
 * @param mac - The mac address.
 * @param nickname - Pointer to a char buffer where the nickname will be stored.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocctlGetNameByAddr(ubyte *mac, byte *nickname);


}



