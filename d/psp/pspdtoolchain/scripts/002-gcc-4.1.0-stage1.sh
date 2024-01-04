#!/bin/sh
# gcc-4.1.0-stage1.sh by Dan Peori (danpeori@oopo.net)

 ## Download the source code.
 wget --continue ftp://ftp.gnu.org/pub/gnu/gcc/gcc-4.1.0/gcc-4.1.0.tar.bz2 || { exit 1; }

 ## Unpack the source code.
 rm -Rf gcc-4.1.0 && tar xfvj gcc-4.1.0.tar.bz2 || { exit 1; }

 ## Enter the source directory and patch the source code.
 cd gcc-4.1.0 && cat ../../patches/gcc-4.1.0-PSP.patch | patch -p1 || { exit 1; }
 

 cd gcc || { exit 1; }
 # Checkout dgcc from svn
 svn co https://dgcc.svn.sourceforge.net/svnroot/dgcc/trunk/d || { exit 1; }
 cd .. || { exit 1; }
 # setup dgcc
 ./gcc/d/setup-gcc.sh --d-language-version=1 || { exit 1; }
 

 ## Create and enter the build directory.
 mkdir build-psp && cd build-psp || { exit 1; }

 ## Configure the build.
 ../configure --prefix="$PSPDEV" --target="psp" --enable-languages="c,d,c++" --with-newlib --enable-cxx-flags="-G0" --disable-libssp --enable-static --disable-shared || { exit 1; }
 
 ## Compile and install.
 make clean || { exit 1; }
 CFLAGS_FOR_TARGET="-G0" make || { exit 1; }
 make install || { exit 1; }
 make clean || { exit 1; }