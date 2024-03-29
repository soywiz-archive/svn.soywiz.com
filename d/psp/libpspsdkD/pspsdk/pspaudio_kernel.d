/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspaudio.h - Prototypes for the sceAudio library.
 *
 * Copyright (c) 2005 Adresd
 * Copyright (c) 2005 Marcus R. Brown <mrbrown@ocgnet.org>
 * Copyright (c) 2007 cooleyes
 * Copyright (c) 2007 Alexander Berl <raphael@fx-world.org>
 *
 * $Id: pspaudio_kernel.h 2341 2007-12-06 20:05:52Z raphael $
 */
module pspsdk.pspaudio_kernel;


extern (C) {


/** @defgroup Audio User Audio Library */

/** @addtogroup Audio */

/*@{*/

enum PspAudioFrequencies {
    /** Sampling frequency set to 44100Hz. */
    PSP_AUDIO_FREQ_44K = 44100,
    /** Sampling frequency set to 48000Hz. */
    PSP_AUDIO_FREQ_48K = 48000
};

/**
  * Set audio sampling frequency
  *
  * @param frequency - Sampling frequency to set audio output to - either 44100 or 48000.
  *
  * @returns 0 on success, an error if less than 0.
  */
int sceAudioSetFrequency(int frequency);
/*@}*/


}



