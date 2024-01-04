PSP_FW_VERSION=300
TARGET_LIB = libpspsdkD.a
OBJS = csystime.o pspatrac3.o pspaudiocodec.o pspaudio.o pspaudio_kernel.o pspaudiolib.o \
pspchnnlsv.o pspctrl.o pspctrl_kernel.o pspdconfig.o pspdebug.o pspdebugkb.o pspdisplay.o \
pspdisplay_kernel.o pspexception.o pspfpu.o pspge.o pspgu.o pspgum.o psphprm.o psphttp.o \
pspidstorage.o pspimpose_driver.o pspinit.o pspintrman.o pspintrman_kernel.o pspiofilemgr.o \
pspiofilemgr_dirent.o pspiofilemgr_fcntl.o pspiofilemgr_kernel.o pspiofilemgr_stat.o pspjpeg.o \
pspkdebug.o pspkernel.o pspkerneltypes.o pspkerror.o psploadcore.o psploadexec.o \
psploadexec_kernel.o pspmoduleexport.o pspmoduleinfo.o pspmodulemgr.o pspmodulemgr_kernel.o \
pspmpegbase.o pspmpeg.o pspmscm.o pspnand_driver.o pspnet_adhocctl.o pspnet_adhoc.o pspnet_adhocmatching.o \
pspnet_apctl.o pspnet.o pspnet_inet.o pspnet_resolver.o pspopenpsid.o psppower.o \
pspprof.o pspreg.o psprtc.o pspsdk.o pspsircs.o pspssl.o pspstdio.o pspstdio_kernel.o pspsuspend.o \
pspsysclib.o  pspsyscon.o pspsysevent.o pspsysmem.o pspsysmem_kernel.o pspsysreg.o \
pspsystimer.o pspthreadman.o pspthreadman_kernel.o psptypes.o pspumd.o pspusbacc.o \
pspusbbus.o pspusbcam.o pspusb.o pspusbstor.o pspuser.o psputility_avmodules.o \
psputility.o psputility_gamesharing.o psputility_htmlviewer.o psputility_modules.o \
psputility_msgdialog.o psputility_netconf.o psputility_netmodules.o psputility_netparam.o \
psputility_osk.o psputility_savedata.o psputility_sysparam.o psputility_usbmodules.o \
psputils.o psputilsforkernel.o pspvfpu.o pspvideocodec.o pspwlan.o


DFLAGS = -I./..
CFLAGS = -O2 -G0 -Wall
CXXFLAGS = $(CFLAGS) -fno-exceptions -fno-rtti
ASFLAGS = $(CFLAGS)

LIBDIR =
LIBS =  # -lgphobos -lpspgum -lpspgu -lm 
LDFLAGS =

PSPSDK=$(shell psp-config --pspsdk-path)
include $(PSPSDK)/lib/build.mak 


