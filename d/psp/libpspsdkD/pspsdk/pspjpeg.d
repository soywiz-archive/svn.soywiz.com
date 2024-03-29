/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspjpeg.h - Prototypes for the sceJpeg library
 *
 * Copyright (c) 2007 dot_blank
 *
 * $Id: pspjpeg.h 2342 2007-12-06 21:49:26Z raphael $
 */
module pspsdk.pspjpeg;

public import pspsdk.psptypes;
public import pspsdk.pspkerneltypes;

extern (C) {

/**
 * Inits the MJpeg library 
 *
 * @returns 0 on success, < 0 on error
*/
int sceJpegInitMJpeg();

/**
 * Finishes the MJpeg library
 *
 * @returns 0 on success, < 0 on error
*/
int sceJpegFinishMJpeg();

/**
 * Creates the decoder context.
 *
 * @param width - The width of the frame
 * @param height - The height of the frame
 *
 * @returns 0 on success, < 0 on error
*/
int sceJpegCreateMJpeg(int width, int height);

/**
 * Deletes the current decoder context.
 *
 * @returns 0 on success, < 0 on error
*/
int sceJpegDeleteMJpeg();

/**
 * Decodes a mjpeg frame.
 *
 * @param jpegbuf - the buffer with the mjpeg frame
 * @param size - size of the buffer pointed by jpegbuf
 * @param rgba - buffer where the decoded data in RGBA format will be stored.
 *				       It should have a size of (width * height * 4).
 * @param unk - Unknown, pass 0
 *
 * @returns (width * 65536) + height on success, < 0 on error 
*/
int sceJpegDecodeMJpeg(u8 *jpegbuf,	SceSize size, void *rgba, u32 unk);


}



