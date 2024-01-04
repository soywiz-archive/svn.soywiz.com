@echo off

pushd ..
call make_lib.bat
popd

rd /q /s gamelib
md gamelib

md gamelib\bin
copy ..\bin\*.dll gamelib\bin

md gamelib\doc
md gamelib\doc\gamelib
xcopy /y /q /e /c ..\www\doc gamelib\doc\gamelib

md gamelib\include
xcopy /y /q /e /c ..\include gamelib\include

md gamelib\lib
xcopy /y /q /e /c ..\lib gamelib\lib

md gamelib\Templates
xcopy /y /q /e /c Templates gamelib\Templates

md gamelib\Icons
copy Templates\gamelib.ico gamelib\Icons

bsdtar -c -j -f gamelib.DevPak gamelib.DevPackage README gamelib

rd /q /s gamelib
