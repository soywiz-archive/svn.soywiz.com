/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspnet_resolver.h - PSP networking libraries.
 *
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@0xd6.org>
 *
 * Portions based on PspPet's wifi_03 sample code.
 * 
 * $Id: pspnet_resolver.h 1661 2006-01-08 13:36:35Z tyranid $
 */

module pspsdk.pspnet_resolver;

import pspsdk.pspkerneltypes;

extern (C) {


// #include <netinet/in.h> // ???
struct in_addr {}

/**
 * Inititalise the resolver library
 *
 * @return 0 on sucess, < 0 on error.
 */
int sceNetResolverInit();

/**
 * Create a resolver object
 *
 * @param rid - Pointer to receive the resolver id
 * @param buf - Temporary buffer
 * @param buflen - Length of the temporary buffer
 *
 * @return 0 on success, < 0 on error
 */
int sceNetResolverCreate(int *rid, void *buf, SceSize buflen);

/**
 * Delete a resolver
 *
 * @param rid - The resolver to delete
 *
 * @return 0 on success, < 0 on error
 */
int sceNetResolverDelete(int rid);

/**
 * Begin a name to address lookup
 *
 * @param rid - Resolver id
 * @param hostname - Name to resolve
 * @param addr - Pointer to in_addr structure to receive the address
 * @param timeout - Number of seconds before timeout
 * @param retry - Number of retires
 *
 * @return 0 on success, < 0 on error
 */
int sceNetResolverStartNtoA(int rid, byte *hostname, in_addr* addr, uint timeout, int retry);

/**
 * Begin a address to name lookup
 *
 * @param rid -Resolver id
 * @param addr - Pointer to the address to resolve
 * @param hostname - Buffer to receive the name
 * @param hostname_len - Length of the buffer
 * @param timeout - Number of seconds before timeout
 * @param retry - Number of retries
 *
 * @return 0 on success, < 0 on error
 */
int sceNetResolverStartAtoN(int rid, in_addr* addr, byte *hostname, SceSize hostname_len, uint timeout, int retry);

/**
 * Stop a resolver operation
 * 
 * @param rid - Resolver id
 * 
 * @return 0 on success, < 0 on error
 */
int sceNetResolverStop(int rid);

/**
 * Terminate the resolver library
 *
 * @return 0 on success, < 0 on error
 */
int sceNetResolverTerm();


}



