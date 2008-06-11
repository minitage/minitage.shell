rem PATHS TO SET
set MPATH=c:\minitage
set PATH=%MPATH%/bin;%MPATH%/tmp;C:\Program Files\Internet Explorer\;c:\Python25;c:\PYTHON25\Scripts;%PATH%

mkdir %MPATH% 
mkdir %MPATH%\tmp 
mkdir %MPATH%\bin

set WGET_URL=http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
set ZIP_URL=ftp://ftp.rz.uni-kiel.de/pub/phc/mw/xiam/dos/unzip.exe
set MINGW_URL=http://surfnet.dl.sourceforge.net/sourceforge/mingw/
set GZIP_URL=ftp://ftp.ee.debian.org/pub/OpenBSD/4.3/tools/gzip.exe
set TAR_URL=ftp://ftp.it.su.se/pub/security/tools/net/mod_ssl/contrib/tar.exe
rem python -c "import os,urllib;open(os.path.join('%MPATH%','bin','wget.exe'),'wb').write(urllib.urlopen('%WGET_URL%').read())"
rem wget -c %ZIP_URL% -O %MPATH%\bin\unzip.exe


rem GZIP & TAR
cd %MPATH%\tmp\
rem del README COPYING
rem wget -c "%GZIP_URL%" -O gzipinst.exe
rem wget -c "%TAR_URL%" -O tar.exe
rem del README 
rem del COPYING 
rem del README.DOS

rem MINGW
cd %MPATH%\tmp\
rem wget -c "%MINGW_URL%"/gcc-ada-3.4.5-20060117-3.tar.gz
rem wget -c "%MINGW_URL%"/gcc-build-3.4.5-20060117-3.tar.gz
rem wget -c "%MINGW_URL%"/gcc-core-3.4.5-20060117-3.tar.gz
rem wget -c "%MINGW_URL%"/gcc-g++-3.4.5-20060117-3.tar.gz
rem wget -c "%MINGW_URL%"/gcc-g77-3.4.5-20060117-3.tar.gz
rem wget -c "%MINGW_URL%"/gcc-java-3.4.5-20060117-3.tar.gz
rem wget -c "%MINGW_URL%"/gcc-objc-3.4.5-20060117-3.tar.gz
cd C:\a poil\hg\shell
cmd