/*
 * PSP Software Development Kit - http://www.pspdev.org
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspvfpu.h - Prototypes for the VFPU library
 *
 * Copyright (c) 2005 Jeremy Fitzhardinge <jeremy@goop.org>
 *
 * $Id: pspvfpu.h 1751 2006-01-26 01:42:38Z jsgf $
 */
module pspsdk.pspvfpu;



extern (C) {


struct pspvfpu_context; /+ ??? +/
alias ubyte vfpumatrixset_t;

const int VMAT0 =	(1<<0);
const int VMAT1 =	(1<<1);
const int VMAT2 =	(1<<2);
const int VMAT3 =	(1<<3);
const int VMAT4 =	(1<<4);
const int VMAT5 =	(1<<5);
const int VMAT6 =	(1<<6);
const int VMAT7 =	(1<<7);

const int VFPU_ALIGNMENT = (float.sizeof * 4);	/* alignment required for VFPU matrix loads and stores */

/**
   Prepare to use the VFPU.  This set's the calling thread's VFPU
   attribute, and returns a pointer to some VFPU state storage.
   The initial value all all VFPU matrix registers is undefined.

   @return A VFPU context
 */
pspvfpu_context *pspvfpu_initcontext();

/**
   Delete a VFPU context.  This frees the resources used by the VFPU
   context.

   @param context The VFPU context to be deleted.
 */
void pspvfpu_deletecontext(pspvfpu_context *context);

/**
   Use a set of VFPU matrices.  This restores the parts of the VFPU
   state the caller wants restored (if necessary).  If the caller was
   the previous user of the the matrix set, then this call is
   effectively a no-op.  If a matrix has never been used by this
   context before, then it will initially have an undefined value.

   @param context The VFPU context the caller wants to restore
   from. It is valid to pass NULL as a context.  This means the caller
   wants to reserve a temporary matrix without affecting other VFPU
   users, but doesn't want any long-term matrices itself.

   @param keepset The set of matrices the caller wants to use, and
   keep the values persistently.  

   @param tempset A set of matrices the callers wants to use
   temporarily, but doesn't care about the values in the long-term.
 */
void pspvfpu_use_matrices(pspvfpu_context *context, 
			  vfpumatrixset_t keepset, vfpumatrixset_t tempset);


}



