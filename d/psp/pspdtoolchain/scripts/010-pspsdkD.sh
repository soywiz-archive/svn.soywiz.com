#!/bin/sh

 ## Download the source code.
 if test ! -d "libpspsdkD"; then
  svn checkout http://svn.soywiz.com/d/psp/libpspsdkD || { exit 1; }
 else
  svn update libpspsdkD || { exit 1; }
 fi

 ## Enter the source directory.
 cd libpspsdkD || { exit 1; }

 cp build.mak $PSPSDK/lib/build.mak || { exit 1; }
 mkdir $PSPSDK/../../include/d/4.1.0/pspsdk
 cp -Rf pspsdk/*.d $PSPSDK/../../include/d/4.1.0/pspsdk/ || { exit 1; }
 cp -Rf pspsdk/*.a $PSPSDK/lib/ || { exit 1; }
