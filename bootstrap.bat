rem """""""""""""""""""""""""""""
rem    VARIABLES
rem """""""""""""""""""""""""""""  
set DRIVE=C
set IE_PATH=C:\Program Files\Internet Explorer
set MPATH=%DRIVE%:\minitage
set MINGWPATH=%MPATH%\mingw
set APERLPATH=%MPATH%\aperl
set MGBINPATH=%MINGWPATH%\bin;%MINGWPATH%\lib;%MINGWPATH%\libexec;%MINGWPATH%\sbin
set PATH=%IE_PATH%;%APERLPATH%\bin;%MPATH%\bin;%MPATH%\tmp;%PATH%;%MGBINPATH%;Z:\projects\repos\hg.minitage.org\shell;
set WGET_HOST=ftp.univ-orleans.fr

set MINGW_URL=http://surfnet.dl.sourceforge.net/sourceforge/mingw
set MINGW_GCCVER=3.4.5-20060117-3
set MINITAGE_MIRROR=http://distfiles.minitage.org/public/externals/minitage/winbins
set BZ2_URL=%MINITAGE_MIRROR%/bzip2.exe
set LIBINTL3_URL=%MINITAGE_MIRROR%/libintl3.dll
set LIBINTL2_URL=%MINITAGE_MIRROR%/libintl-2.dll
set LIBICONV2_URL=%MINITAGE_MIRROR%/libiconv2.dll
set SED_URL=%MINITAGE_MIRROR%/sed.exe
set BZ2CAT_URL=%MINITAGE_MIRROR%/bzcat.exe
set BZ2DLL_URL=%MINITAGE_MIRROR%/bzip2.dll
set GZIP_URL=%MINITAGE_MIRROR%/gzip.exe
set WHICH_URL=%MINITAGE_MIRROR%/which.exe
set GUNZIP_URL=%MINITAGE_MIRROR%/gunzip
set ZIP_URL=%MINITAGE_MIRROR%/unzip.exe
set TAR_URL=%MINITAGE_MIRROR%/tar.exe
set WGET_URL=%MINITAGE_MIRROR%/wget.exe
set MSYS_VER=1.0.11-1
set APERL_FILE=ActivePerl-5.10.0.1003-MSWin32-x86-285500.zip
set APERL_URL=http://downloads.activestate.com/ActivePerl/Windows/5.10/

rem """""""""""""""""""""""""""""
rem    INIT
rem """"""""""""""""""""""""""""" 
mkdir %MPATH% 
mkdir %MPATH%\bin
mkdir %MINGWPATH%
mkdir %APERLPATH%
pushd %MINGWPATH%
mkdir bin
popd
mkdir %MPATH%\tmp 
pushd %MPATH%\tmp
mkdir mingw
mkdir aperl
popd

rem rem """""""""""""""""""""""""""""
rem rem    wget
rem rem """""""""""""""""""""""""""""
rem pushd %MPATH%\tmp
rem iexplore "%WGET_URL%"
rem wget -c "%BZ2_URL%"
rem wget -c "%BZ2DLL_URL%"
rem wget -c "%LIBICONV2_URL%"
rem wget -c "%BZ2CAT_URL%"
rem wget -c "%GZIP_URL%"
rem wget -c "%GUNZIP_URL%"
rem wget -c "%LIBINTL2_URL%"
rem wget -c "%TAR_URL%" 
rem wget -c "%ZIP_URL%" 
rem popd
rem 
rem rem """""""""""""""""""""""""""""
rem rem     GNU%WIN32 stuff
rem rem """"""""""""""""""""""""""""" 
rem pushd  %MINGWPATH%\bin
rem wget -c "%SED_URL%" -O gsed.exe
rem wget -c "%WHICH_URL%"
rem wget -c "%LIBINTL3_URL%"
rem wget -c "%LIBICONV2_URL%"
rem popd 
rem 
rem rem """""""""""""""""""""""""""""
rem rem     MINGW
rem rem """""""""""""""""""""""""""""
rem pushd %MPATH%\tmp\mingw
rem wget -c "%MINGW_URL%"/gcc-ada-%MINGW_GCCVER%.tar.gz
rem wget -c "%MINGW_URL%"/gcc-build-%MINGW_GCCVER%.tar.gz
rem wget -c "%MINGW_URL%"/gcc-core-%MINGW_GCCVER%.tar.gz
rem wget -c "%MINGW_URL%"/gcc-g++-%MINGW_GCCVER%.tar.gz
rem wget -c "%MINGW_URL%"/gcc-g77-%MINGW_GCCVER%.tar.gz
rem wget -c "%MINGW_URL%"/gcc-java-%MINGW_GCCVER%.tar.gz
rem wget -c "%MINGW_URL%"/gcc-objc-%MINGW_GCCVER%.tar.gz
rem wget -c "%MINGW_URL%"/binutils-2.18.50-20080109-2.tar.gz  
rem wget -c "%MINGW_URL%"/mingw-runtime-3.14.tar.gz
rem wget -c "%MINGW_URL%"/mingw-utils-0.3.tar.gz    
rem wget -c "%MINGW_URL%"/w32api-3.11.tar.gz   
rem wget -c "%MINGW_URL%"/cpmake-3.81-MSYS-%MSYS_VER%-bin.tar.gz
rem wget -c "%MINGW_URL%"/vim-7.1-MSYS-%MSYS_VER%-bin.tar.gz   
rem wget -c "%MINGW_URL%"/lzma-4.43-MSYS-%MSYS_VER%-bin.tar.gz   
rem wget -c "%MINGW_URL%"/mingw32-make-3.81-20080326-3.tar.gz
rem wget -c "%MINGW_URL%"/tar-1.19.90-MSYS-%MSYS_VER%-bin.tar.gz  
rem wget -c "%MINGW_URL%"/wget-1.9.1.tar.gz   
rem wget -c "%MINGW_URL%"/autogen-5.9.2-MSYS-%MSYS_VER%-bin.tar.gz  
rem wget -c "%MINGW_URL%"/cvs-1.11.22-MSYS-%MSYS_VER%-bin.tar.gz
rem wget -c "http://surfnet.dl.sourceforge.net/sourceforge/mingw/openssl-0.9.8g-1-MSYS-1.0.11-2-bin.tar.gz"
rem 
rem wget -c "%MINGW_URL%"/automake1.10-1.10-1-bin.tar.bz2  
rem wget -c "%MINGW_URL%"/bash-3.1-MSYS-%MSYS_VER%.tar.bz2
rem wget -c "%MINGW_URL%"/gdb-6.8-mingw-3.tar.bz2
rem wget -c "%MINGW_URL%"/MSYS-1.0.11-20071204.tar.bz2    
rem wget -c "%MINGW_URL%"/bison-2.3-MSYS-%MSYS_VER%.tar.bz2   
rem wget -c "%MINGW_URL%"/bzip2-1.0.3-MSYS-%MSYS_VER%.tar.bz2  
rem wget -c "%MINGW_URL%"/msysCORE-1.0.11-2007.01.19-1.tar.bz2    
rem wget -c "%MINGW_URL%"/coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2
rem wget -c "%MINGW_URL%"/crypt-1.1-1-MSYS-%MSYS_VER%.tar.bz2    
rem wget -c "%MINGW_URL%"/csmake-3.81-MSYS-1.0.11-2.tar.bz2
rem wget -c "%MINGW_URL%"/diffutils-2.8.7-MSYS-%MSYS_VER%.tar.bz2   
rem wget -c "%MINGW_URL%"/findutils-4.3-MSYS-%MSYS_VER%.tar.bz2
rem wget -c "%MINGW_URL%"/flex-2.5.33-MSYS-%MSYS_VER%.tar.bz2
rem wget -c "%MINGW_URL%"/gawk-3.1.5-MSYS-%MSYS_VER%.tar.bz2   
rem wget -c "%MINGW_URL%"/gdbm-1.8.3-MSYS-%MSYS_VER%.tar.bz2   
rem wget -c "%MINGW_URL%"/gettext-0.16.1-1-bin.tar.bz2  
rem wget -c "%MINGW_URL%"/libiconv-1.11-1-bin.tar.bz2  
rem wget -c "%MINGW_URL%"/make-3.81-MSYS-1.0.11-2.tar.bz2   
rem wget -c "%MINGW_URL%"/perl-5.6.1-MSYS-%MSYS_VER%.tar.bz2   
rem wget -c "%MINGW_URL%"/tcltk-8.4.1-src-1.tar.bz2
rem wget -c "%MINGW_URL%"/texinfo-4.11-MSYS-%MSYS_VER%.tar.bz2 
rem wget -c "%MINGW_URL%"/zlib-1.2.3-MSYS-%MSYS_VER%.tar.bz2   
rem wget -c "%MINGW_URL%"/termcap-20050421-MSYS-%MSYS_VER%.tar.bz2
rem wget -c "%MINGW_URL%"/autoconf-2.61-MSYS-%MSYS_VER%.tar.bz2  
rem wget -c "%MINGW_URL%"/automake-1.10-MSYS-%MSYS_VER%.tar.bz2   
rem wget -c "%MINGW_URL%"/libtool1.5-1.5.25a-20070701-MSYS-%MSYS_VER%.tar.bz2  
rem popd
rem rem """""""""""""""""""""""""""""
rem rem    UNCOMPRESS
rem rem """""""""""""""""""""""""""""
rem pushd  %MINGWPATH%
rem for %%f in (%MPATH%\tmp\mingw\*.gz) do gzip.exe -c -d %%f|tar xvf -
rem for %%f in (%MPATH%\tmp\mingw\*.bz2) do bzip2 -kcd %%f|tar xvf -
rem popd
rem 
rem rem """""""""""""""""""""""""""""
rem rem     ACTIVE PERL
rem rem """""""""""""""""""""""""""""  
rem pushd %MPATH%\tmp\aperl
rem rem wget -c %APERL_URL%/%APERL_FILE%
rem rem unzip -o Active~1
rem cd A*
rem cd perl
rem xcopy /E /Y * %APERLPATH%
rem cd ..
rem del /F /S /Q  perl
rem popd

rem      
rem      rem """""""""""""""""""""""""""""
rem      rem     BOOTSTRAPPER
rem      rem """""""""""""""""""""""""""""  
rem      pushd  %MINGWPATH%\tmp
rem      wget http://hg.minitage.org/hg/minitage/shell/raw-file/tip/PyBootstrapper.sh
rem      popd
rem      
rem      


rem  echo export PATH='%PATH%;/sbin;/usr/sbin;/usr/local;/sbin;/bin;/lib;/usr/bin;/usr/local/bin;/usr/local/lib;/lib;/usr/lib'|gsed -re "s/C:/c:/g"|gsed -re "s/D:/d:/g"|gsed -re "s/E:/e:/g"|gsed -re "s/F:/f:/g"|gsed -re "s/G:/g:/g"|gsed -re "s/H:/h:/g"|gsed -re "s/Z:/z:/g"|gsed -re "s/Y:/y:/g"|gsed -re "s/X:/x:/g"|gsed -re "s/W:/w:/g"|gsed -re "s/V:/v:/g"|gsed -re "s/U:/u:/g"|gsed -re "s/T:/t:/g"|gsed -re "s/S:/s:/g"|gsed -re "s/R:/r:/g"|gsed -re "s/Q:/q:/g"|    gsed -re "s|(.):\\|/\1/|g"|gsed "s|\\|/|g"|gsed -re "s/;/:/g">%MINGWPATH%\.bashrc





cmd
