@echo off
dmd -release -inline -O -ofCDVDfs.dll -v1 dll.d iso.d CDVD.d CDVD.def
del CDVD.obj dll.obj
del CDVDfs.map
REM del