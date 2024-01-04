/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspnet_adhoc.h - PSP Adhoc networking libraries.
 *
 * Copyright (c) 2006 James F.
 * Copyright (c) 2008 InsertWittyName <tias_dp@hotmail.com>
 *
 * Based on the adhoc code in SMS Plus
 * 
 * $Id: pspnet_adhoc.h 2362 2008-02-02 14:09:22Z iwn $
 */
module pspsdk.pspnet_adhoc;


extern (C) {


/** 
 * Initialise the adhoc library.
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocInit(  );

/**
 * Terminate the adhoc library
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocTerm(  );

/**
 * Create a PDP object.
 *
 * @param mac - Your MAC address (from sceWlanGetEtherAddr)
 * @param port - Port to use, lumines uses 0x309
 * @param unk2 - Unknown, lumines sets to 0x400
 * @param unk3 - Unknown, lumines sets to 0
 *
 * @return The ID of the PDP object (< 0 on error)
 */
int sceNetAdhocPdpCreate(ubyte *mac, ushort port, uint unk2, int unk3);

/**
 * Delete a PDP object.
 *
 * @param id - The ID returned from ::sceNetAdhocPdpCreate
 * @param unk1 - Unknown, set to 0
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocPdpDelete(int id, int unk1); 

/**
 * Set a PDP packet to a destination
 *
 * @param id - The ID as returned by ::sceNetAdhocPdpCreate
 * @param destMacAddr - The destination MAC address, can be set to all 0xFF for broadcast
 * @param port - The port to send to
 * @param data - The data to send
 * @param len - The length of the data.
 * @param unk6 - Unknown, set to 0
 * @param unk7 - Unknown, set to 0
 *
 * @return Bytes sent, < 0 on error
 */
int sceNetAdhocPdpSend(int id, ubyte *destMacAddr, ushort port, void *data, uint len, int unk6, int unk7); 

/**
 * Receive a PDP packet
 *
 * @param id - The ID of the PDP object, as returned by ::sceNetAdhocPdpCreate
 * @param srcMacAddr - Buffer to hold the source mac address of the sender
 * @param port - Buffer to hold the port number of he received data
 * @param data - Data buffer
 * @param dataLength - The length of the data buffer
 * @param unk6 - Set to 0
 * @param unk7 - Set to 0
 *
 * @return Number of bytes received, < 0 on error.
 */
int sceNetAdhocPdpRecv(int id, ubyte *srcMacAddr, ushort *port, void *data, void *dataLength, int unk6, int unk7);

/**
 * PDP status structure
 */
struct pdpStatStruct
{
	/** Pointer to next PDP structure in list */
	pdpStatStruct *next;
	/** pdp ID */
	int pdpId;
	/** MAC address */
	ubyte mac[6];
	/** Port */
	ushort port;
	/** Bytes received */
	uint rcvdData;
}

/**
 * Get the status of all PDP objects
 *
 * @param size - Pointer to the size of the stat array (e.g 20 for one structure)
 * @param stat - Pointer to a list of ::pspStatStruct structures.
 *
 * @return 0 on success, < 0 on error
 */
int sceNetAdhocGetPdpStat(int *size, pdpStatStruct *stat);

/**
 * Create own game object type data.
 *
 * @param data - A pointer to the game object data.
 * @param size - Size of the game data.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocGameModeCreateMaster(void *data, int size);

/**
 * Create peer game object type data.
 *
 * @param mac - The mac address of the peer.
 * @param data - A pointer to the game object data.
 * @param size - Size of the game data.
 *
 * @return The id of the replica on success, < 0 on error.
 */
int sceNetAdhocGameModeCreateReplica(ubyte *mac, void *data, int size);

/**
 * Update own game object type data.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocGameModeUpdateMaster();

/**
 * Update peer game object type data.
 *
 * @param id - The id of the replica returned by sceNetAdhocGameModeCreateReplica.
 * @param unknown - Pass 0.
 * @param unknown2 - Pass 0.
 * @param unknown3 - Pass 0.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocGameModeUpdateReplica(int id, int unknown, int unknown2, int unknown3);

/**
 * Open a PTP connection
 *
 * @param srcmac - Local mac address.
 * @param srcport - Local port.
 * @param destmac - Destination mac.
 * @param destport - Destination port
 * @param bufsize - Socket buffer size
 * @param delay - Interval between retrying (microseconds).
 * @param count - Number of retries.
 * @param unk1 - Pass 0.
 *
 * @return A socket ID on success, < 0 on error.
 */
int sceNetAdhocPtpOpen(ubyte *srcmac, ushort srcport, ubyte *destmac, ushort destport, uint bufsize, uint delay, int count, int unk1);

/**
 * Wait for connection created by sceNetAdhocPtpOpen()
 *
 * @param id - A socket ID.
 * @param timeout - Timeout in microseconds.
 * @param unk1 - Pass 0.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocPtpConnect(int id, uint timeout, int unk1);

/**
 * Wait for an incoming PTP connection
 *
 * @param srcmac - Local mac address.
 * @param srcport - Local port.
 * @param bufsize - Socket buffer size
 * @param delay - Interval between retrying (microseconds).
 * @param count - Number of retries.
 * @param queue - Connection queue length.
 * @param unk2 - Pass 0.
 *
 * @return A socket ID on success, < 0 on error.
 */
int sceNetAdhocPtpListen(ubyte *srcmac, ushort srcport, uint bufsize, uint delay, int count, int queue, int unk2);

/**
 * Accept an incoming PTP connection
 *
 * @param id - A socket ID.
 * @param mac - Connecting peers mac.
 * @param port - Connecting peers port.
 * @param timeout - Timeout in microseconds.
 * @param unk1 - Pass 0.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocPtpAccept(int id, ubyte *mac, ushort *port, uint timeout, int unk1);

/**
 * Send data
 *
 * @param id - A socket ID.
 * @param data - Data to send.
 * @param datasize - Size of the data.
 * @param timeout - Timeout in microseconds.
 * @param unk1 - Pass 0.
 *
 * @return 0 success, < 0 on error.
 */
int sceNetAdhocPtpSend(int id, void *data, int *datasize, uint timeout, int unk1);

/**
 * Receive data
 *
 * @param id - A socket ID.
 * @param data - Buffer for the received data.
 * @param datasize - Size of the data received.
 * @param timeout - Timeout in microseconds.
 * @param unk1 - Pass 0.
 *
 * @return 0 on success, < 0 on error.
 */
int sceNetAdhocPtpRecv(int id, void *data, int *datasize, uint timeout, int unk1);

/**
 * Wait for data in the buffer to be sent
 *
 * @param id - A socket ID.
 * @param timeout - Timeout in microseconds.
 * @param unk1 - Pass 0.
 *
 * @return A socket ID on success, < 0 on error.
 */
int sceNetAdhocPtpFlush(int id, uint timeout, int unk1);

/**
 * Close a socket
 *
 * @param id - A socket ID.
 * @param unk1 - Pass 0.
 *
 * @return A socket ID on success, < 0 on error.
 */
int sceNetAdhocPtpClose(int id, int unk1);


}



