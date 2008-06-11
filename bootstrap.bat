rem """""""""""""""""""""""""""""
rem    VARIABLES
rem """""""""""""""""""""""""""""  
set DRIVE=C
set MPATH=%DRIVE%:\minitage
set MINGWPATH=%MPATH%\mingw
set MGBINPATH=%MINGWPATH%\bin;%MINGWPATH%\lib;%MINGWPATH%\libexec;%MINGWPATH%\sbin
set PATH=%MPATH%\bin;%MPATH%\tmp;%PATH%;%MGBINPATH%;Z:\projects\repos\hg.minitage.org\shell;
set WGET_HOST=ftp.univ-orleans.fr
set WGET_PATH=/tex/PC/AsTeX/download/wget.exe
set ZIP_URL=ftp://ftp.rz.uni-kiel.de/pub/phc/mw/xiam/dos/unzip.exe
set MINGW_URL=http://surfnet.dl.sourceforge.net/sourceforge/mingw
set MINGW_GCCVER=3.4.5-20060117-3
set BZ2_URL=http://distfiles.minitage.org/public/externals/minitage/bzip2.exe
set BZ2CAT_URL=http://distfiles.minitage.org/public/externals/minitage/bzcat.exe
set BZ2DLL_URL=http://distfiles.minitage.org/public/externals/minitage/bzip2.dll
set GZIP_URL=http://distfiles.minitage.org/public/externals/minitage/gzip.exe
set WHICH_URL=http://distfiles.minitage.org/public/externals/minitage/which.exe
set GUNZIP_URL=http://distfiles.minitage.org/public/externals/minitage/gunzip
set TAR_URL=ftp://ftp.it.su.se/pub/security/tools/net/mod_ssl/contrib/tar.exe
set MSYS_VER=1.0.11-1
 
 
rem """""""""""""""""""""""""""""
rem    INIT
rem """"""""""""""""""""""""""""" 
mkdir %MPATH% 
mkdir %MPATH%\tmp 
mkdir %MPATH%\bin
 
rem """""""""""""""""""""""""""""
rem    wget
rem """""""""""""""""""""""""""""
pushd %MPATH%\tmp\
rem                  echo open %WGET_HOST%>>ftpcmd.bat
rem                  echo user anonymous anon@anon.fr>>ftpcmd.bat
rem                  echo bin>>ftpcmd.bat
rem                  echo get %WGET_PATH%>>ftpcmd.bat
rem                  echo bye>>ftpcmd.bat
rem                  ftp -n -d -s:ftpcmd.bat
rem                  del ftpcmd.bat
rem                  wget -c "%BZ2_URL%"
rem                  wget -c "%BZ2DLL_URL%"
rem                  wget -c "%BZ2CAT_URL%"
rem                  wget -c "%GZIP_URL%"
rem                  wget -c "%GUNZIP_URL%"
rem                  wget -c "%TAR_URL%" -O tar.exe
rem                  gzipinst
rem                  del README 
rem                  del COPYING 
rem                  del README.DOS
popd

rem """""""""""""""""""""""""""""
rem     MINGW
rem """""""""""""""""""""""""""""
pushd %MPATH%\tmp\
mkdir mingw
pushd mingw
rem                         wget -c "%MINGW_URL%"/gcc-ada-%MINGW_GCCVER%.tar.gz
rem                         wget -c "%MINGW_URL%"/gcc-build-%MINGW_GCCVER%.tar.gz
rem                         wget -c "%MINGW_URL%"/gcc-core-%MINGW_GCCVER%.tar.gz
rem                         wget -c "%MINGW_URL%"/gcc-g++-%MINGW_GCCVER%.tar.gz
rem                         wget -c "%MINGW_URL%"/gcc-g77-%MINGW_GCCVER%.tar.gz
rem                         wget -c "%MINGW_URL%"/gcc-java-%MINGW_GCCVER%.tar.gz
rem                         wget -c "%MINGW_URL%"/gcc-objc-%MINGW_GCCVER%.tar.gz
rem                         wget -c "%MINGW_URL%"/binutils-2.18.50-20080109-2.tar.gz  
rem                         wget -c "%MINGW_URL%"/mingw-runtime-3.14.tar.gz
rem                         wget -c "%MINGW_URL%"/mingw-utils-0.3.tar.gz    
rem                         wget -c "%MINGW_URL%"/w32api-3.11.tar.gz   
rem                         wget -c "%MINGW_URL%"/cpmake-3.81-MSYS-%MSYS_VER%-bin.tar.gz
rem                         wget -c "%MINGW_URL%"/vim-7.1-MSYS-%MSYS_VER%-bin.tar.gz   
rem                         wget -c "%MINGW_URL%"/lzma-4.43-MSYS-%MSYS_VER%-bin.tar.gz   
rem                         wget -c "%MINGW_URL%"/mingw32-make-3.81-20080326-3.tar.gz
rem                         wget -c "%MINGW_URL%"/tar-1.19.90-MSYS-%MSYS_VER%-bin.tar.gz  
rem                         wget -c "%MINGW_URL%"/wget-1.9.1.tar.gz   
rem                         wget -c "%MINGW_URL%"/autogen-5.9.2-MSYS-%MSYS_VER%-bin.tar.gz  
rem                         wget -c "%MINGW_URL%"/cvs-1.11.22-MSYS-%MSYS_VER%-bin.tar.gz
rem                         wget -c "http://surfnet.dl.sourceforge.net/sourceforge/mingw/openssl-0.9.8g-1-MSYS-1.0.11-2-bin.tar.gz"
rem                      
rem                         wget -c "%MINGW_URL%"/automake1.10-1.10-1-bin.tar.bz2  
rem                         wget -c "%MINGW_URL%"/bash-3.1-MSYS-%MSYS_VER%.tar.bz2
rem                         wget -c "%MINGW_URL%"/gdb-6.8-mingw-3.tar.bz2
rem                         wget -c "%MINGW_URL%"/MSYS-1.0.11-20071204.tar.bz2    
rem                         wget -c "%MINGW_URL%"/bison-2.3-MSYS-%MSYS_VER%.tar.bz2   
rem                         wget -c "%MINGW_URL%"/bzip2-1.0.3-MSYS-%MSYS_VER%.tar.bz2  
rem                         wget -c "%MINGW_URL%"/msysCORE-1.0.11-2007.01.19-1.tar.bz2    
rem                         wget -c "%MINGW_URL%"/coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2
rem                         wget -c "%MINGW_URL%"/crypt-1.1-1-MSYS-%MSYS_VER%.tar.bz2    
rem                         wget -c "%MINGW_URL%"/csmake-3.81-MSYS-1.0.11-2.tar.bz2
rem                         wget -c "%MINGW_URL%"/diffutils-2.8.7-MSYS-%MSYS_VER%.tar.bz2   
rem                         wget -c "%MINGW_URL%"/findutils-4.3-MSYS-%MSYS_VER%.tar.bz2
rem                         wget -c "%MINGW_URL%"/flex-2.5.33-MSYS-%MSYS_VER%.tar.bz2
rem                         wget -c "%MINGW_URL%"/gawk-3.1.5-MSYS-%MSYS_VER%.tar.bz2   
rem                         wget -c "%MINGW_URL%"/gdbm-1.8.3-MSYS-%MSYS_VER%.tar.bz2   
rem                         wget -c "%MINGW_URL%"/gettext-0.16.1-1-bin.tar.bz2  
rem                         wget -c "%MINGW_URL%"/libiconv-1.11-1-bin.tar.bz2  
rem                         wget -c "%MINGW_URL%"/make-3.81-MSYS-1.0.11-2.tar.bz2   
rem                         wget -c "%MINGW_URL%"/perl-5.6.1-MSYS-%MSYS_VER%.tar.bz2   
rem                         wget -c "%MINGW_URL%"/tcltk-8.4.1-src-1.tar.bz2
rem                         wget -c "%MINGW_URL%"/texinfo-4.11-MSYS-%MSYS_VER%.tar.bz2 
rem                         wget -c "%MINGW_URL%"/zlib-1.2.3-MSYS-%MSYS_VER%.tar.bz2   
rem                         wget -c "%MINGW_URL%"/termcap-20050421-MSYS-%MSYS_VER%.tar.bz2
rem                         wget -c "%MINGW_URL%"/autoconf-2.61-MSYS-%MSYS_VER%.tar.bz2  
rem                         wget -c "%MINGW_URL%"/automake-1.10-MSYS-%MSYS_VER%.tar.bz2   
rem                         wget -c "%MINGW_URL%"/libtool1.5-1.5.25a-20070701-MSYS-%MSYS_VER%.tar.bz2  
popd

pushd  %MINGWPATH%
rem for %%f in (%MPATH%\tmp\mingw\*.gz) do gzip.exe -c -d %%f|tar xvf -
rem for %%f in (%MPATH%\tmp\mingw\*.bz2) do bzip2 -kcd %%f|tar xvf -

rem """""""""""""""""""""""""""""
rem     GNU%WIN32 stuff
rem """"""""""""""""""""""""""""" 
pushd  %MINGWPATH%\bin
wget %WHICH_URL%
popd
cmd
