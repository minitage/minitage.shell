rem """""""""""""""""""""""""""""
rem    VARIABLES
rem """""""""""""""""""""""""""""
rem
rem !!!!!!!!! WARNING: LOWERCASE THERE !!!!!!!!!!!
SET DRIVE=c
rem !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
rem As we deal with win32 & unix pathes, we have 2 variables 
rem to edit.
SET MPATH=%DRIVE%:\minitage_test
SET LMPATH=/cygdrive/%DRIVE%/minitage_test
rem !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
rem !!!!! DO NOT CHANGE, MINITAGE INTERNALS
SET PYTHONPREFIX=%MPATH%\python
SET CYGPREFIX=%MPATH%\cygwin\root
SET LCYGPREFIX=%LMPATH%/cygwin/root
SET MINITAGE_MIRROR=http://distfiles.minitage.org/public/externals/minitage/winbins
SET BZIP2_URL=%MINITAGE_MIRROR%/bzip2.exe
SET MOUNT_URL=%MINITAGE_MIRROR%/mount.exe
SET TAR_URL=%MINITAGE_MIRROR%/tar.exe
SET UNZIP_URL=%MINITAGE_MIRROR%/unzip.exe
SET WGET_URL=%MINITAGE_MIRROR%/wget.exe
SET CYGICONV2_URL=%MINITAGE_MIRROR%/cygiconv-2.dll
SET CYGINTL8_URL=%MINITAGE_MIRROR%/cygintl-8.dll
SET CYGWIN1_URL=%MINITAGE_MIRROR%/cygwin1.dll
SET CYGWIN_URL=%MINITAGE_MIRROR%/cygwin.zip
SET PATH=%CYGPREFIX%\bin;%CYGPREFIX%\sbin;%PATH%;
SET PATH=%PYTHONPREFIX%\bin;%PYTHONPREFIX%\sbin;%PATH%;
SET PATH=%MPATH%\tmp;%PATH%;
SET PATH=C:\Program Files\Internet Explorer;%PATH%;
SET B=/cygdrive/z/projects/repos/hg.minitage.org/shell/PyBootstrapper.sh
set PYBOOTSTRAPPER=PyBootstrapper.sh
SET PYBOOTSTRAPPER_URL=http://hg.minitage.org/hg/minitage/shell/raw-file/tip/%PYBOOTSTRAPPER%

rem """""""""""""""""""""""""""""
rem    INIT
rem """""""""""""""""""""""""""""
mkdir %CYGPREFIX%
mkdir %CYGPREFIX%\..\downloads
mkdir %MPATH%\tmp

rem
rem     rem """""""""""""""""""""""""""""
rem     rem    wget & utils
rem     rem """""""""""""""""""""""""""""
rem     pushd %MPATH%\tmp
rem     rem iexplore "%WGET_URL%"
rem     wget -c "%BZIP2_URL%"
rem     wget -c "%MOUNT_URL%"
rem     wget -c "%TAR_URL%"
rem     wget -c "%UNZIP_URL%"
rem     wget -c "%CYGICONV2_URL%"
rem     wget -c "%CYGINTL8_URL%"
rem     wget -c "%CYGWIN1_URL%"
rem     wget -c "%CYGWIN_URL%"
rem     rem  the archive is something like:
rem     rem  .\
rem     rem   tar.exe
rem     rem   mount.exe
rem     rem   bzip2.exe
rem     rem   *.dll
rem     rem   cygwin.tbz2(compressed):
rem     rem     z root/
rem     rem     z downloads/
rem     rem     z setup.exe
rem     rem   unzip %CYGPREFIX%\..
rem     popd

rem rem """""""""""""""""""""""""""""
rem rem    cygwin
rem rem """""""""""""""""""""""""""""
rem minitage bootstrapper with cygwin
pushd %CYGPREFIX%\..
rem tar xjpvf '%LMPATH%/tmp/cygwin.tbz2'
popd
pushd %MPATH%\tmp
echo mount -f -s -b "%CYGPREFIX%" "/"                 >"%CYGPREFIX%/mount.bat"
echo mount -f -s -b "%CYGPREFIX%/bin" "/usr/bin"      >>"%CYGPREFIX%/mount.bat"
echo mount -f -s -b "%CYGPREFIX%/lib" "/usr/lib"      >>"%CYGPREFIX%/mount.bat"
echo mount -s -b --change-cygdrive-prefix "/cygdrive" >>"%CYGPREFIX%/mount.bat"
bash -c "%LCYGPREFIX%/mount.bat"
bash -c "cd %LCYGPREFIX%;wget %PYBOOTSTRAPPER_URL% -O %PYBOOTSTRAPPER%;chmod +x %PYBOOTSTRAPPER%;./%PYBOOTSTRAPPER% %LMPATH%/python"
popd

cmd
rem
rem   rem """""""""""""""""""""""""""""
rem   rem     BOOTSTRAPPER
rem   rem """""""""""""""""""""""""""""
rem   pushd  %MINGWPATH%\tmp
rem   bash -c PyBootstrapper.sh %PYTHONPREFIX%
rem   popd

