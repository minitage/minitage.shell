#!/usr/bin/env bash
# Copyright (C)2007 'Mathieu PASQUET <kiorky@cryptelium.net> '
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING. If not, write to the
# Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
version="1.0"
offline=""

UNAME="$(uname)"

MD5SUM="$(which md5sum)"
if [[ -f $(which md5 2>/dev/null) ]];then
    MD5SUM="md5 -q"
fi

# export PATH to have bzip2 and our perso binaries everywhere
export PATH="$prefix/bin:$prefix:/sbin:$PATH"

# freebsd
if [[ $(uname) == "FreeBSD" ]];then
    if [[ -f $(which fetch 2>&1) ]];then
        wget="$(which fetch) -pra -o"
    fi
#another macosx hack
elif [[ -f $(which curl 2>&1) ]];then
    wget="$(which curl) -a -o"
elif [[ -f $(which wget) ]];then
    wget="$(which wget)  -c -O"
fi


if [[ -f $(which gsed 2>&1) ]];then
SED="$(which gsed)"
else
    SED="$(which sed)"
fi

#gentoo_mirror="ftp://gentoo.imj.fr/pub"
gentoo_mirror="http://gentoo.tiscali.nl/"
gentoo_mirror="$gentoo_mirror"

gnu_mirror="http://ftp.gnu.org/pub/gnu"

readline_mirror="http://distfiles.minitage.org/public/externals/minitage/readline-6.1.tar.gz"
readline_md5="fc2f7e714fe792db1ce6ddc4c9fb4ef3"

bz2_mirror="$gentoo_mirror/distfiles/bzip2-1.0.6.tar.gz"
bz2_md5="00b516f4704d4a7cb50a1d97e6e8e15b"
bz2_darwinpatch="http://distfiles.minitage.org/public/externals/minitage/patch-Makefile-dylib.diff"
bz2_darwinpatch_md5="7f42ae89030ebe7279c80c2119f4b29d"

zlib_mirror="$gentoo_mirror/distfiles/zlib-1.2.3.tar.bz2"
zlib_md5="dee233bf288ee795ac96a98cc2e369b6"

ncurses_mirror="$gnu_mirror/ncurses/ncurses-5.7.tar.gz"
ncurses_md5="cce05daf61a64501ef6cd8da1f727ec6"

python24_mirror="http://www.python.org/ftp/python/2.4.6/Python-2.4.6.tar.bz2"
python24_md5="76083277f6c7e4d78992f36d7ad9018d"
python25_mirror="http://python.org/ftp/python/2.5.4/Python-2.5.4.tar.bz2"
python25_md5="394a5f56a5ce811fb0f023197ec0833e"
python26_mirror="http://python.org/ftp/python/2.6.6/Python-2.6.6.tar.bz2"
python26_md5="cf4e6881bb84a7ce6089e4a307f71f14"
python_mirror=$python26_mirror
python_md5=$python26_md5

openssl_mirror="http://www.openssl.org/source/openssl-1.0.0d.tar.gz"
openssl_md5="40b6ea380cc8a5bf9734c2f8bf7e701e"

ez_mirror="http://python-distribute.org/distribute_setup.py"
ez_md5="94ce3ba3f5933e3915e999c26da9563b"
ez_md5="494757ae608c048e1c491c5d4e0a81e6"
ez_md5="ce4f96fd7afac7a6702d7a45f665d176"
ez_md5="ce4f96fd7afac7a6702d7a45f665d176"
ez_md5=""

virtualenv_mirror="http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.5.1.tar.gz"
virtualenv_md5="3daa1f449d5d2ee03099484cecb1c2b7"

hg_mirror="http://hg.intevation.org/files/mercurial-1.0.tar.gz"
hg_md5="9f8dd7fa6f8886f77be9b923f008504c"


# pretty term colors
GREEN=$'\e[32;01m'
YELLOW=$'\e[33;01m'
RED=$'\e[31;01m'
rLUE=$'\e[34;01m'
NORMAL=$'\e[0m'

# display an error message and exit
die() {
    echo $@
    exit -1
}

# silently enter a directory
qpushd() {
    pushd "$1" 2>&1 >> /dev/null
}

# silently go outside a directory
qpopd() {
    popd    2>&1 >> /dev/null
}

check_md5() {
    if [[ "$md5" != "$file_md5" ]];then
        echo "WARNING:! md5 for $myfullpath failed : $md5 != $file_md5 !"
    fi
    if [[ ! -e "$myfullpath" ]];then
        die "$myfullpath"
    fi
}

# download in installdir/downloads
# $1: download URL. The last part of the URL will be the file name by default
# $2: file name's md5
# $3: file name
#don't put "/" at the end of the URL or provide a file name
download(){
    local md5="$2" myfile="$3" url="$1" mydest=""
    if [[ -n "$url" ]];then
        if [[ ! -e "$download_dir" ]];then
            mkdir -p "$download_dir" || die "cant create download dir: $download_dir"
        fi
        if [[ -z "$myfile" ]];then
            myfile="$(give_filename_from_url $url)"
        fi
        mydest="$download_dir/$myfile"
        # offline mode
        if [[ ! -f "$mydest" ]] && [[ -n "$offline" ]];then
            die "file $mydest does not exists!!!"
        fi
        if [[ -e "$mydest" ]];then
            file_md5="$($MD5SUM $mydest|awk '{print $1}')"
        fi
        if [[ -z "$offline" ]] && [[ "$md5" != "$file_md5" ]];then
            $wget "$mydest" "$url"
            file_md5="$($MD5SUM $mydest|awk '{print $1}')"
        fi
        if [[ "$md5" != "$file_md5" ]];then
            if [[ -n "$md5" ]];then
                echo  "!!!!!!!!!!!!! WARNING !!!!!!!!!!!!!! $myfile doesn't match the md5 "$md5" ($file_md5)"
            fi
        fi
        echo "Downloaded $mydest"
    fi
}

# get mas os patches
get_macos_patches() {
    # openssl
    download http://distfiles.minitage.org/public/externals/minitage/patches/openssl-0.9.8h-macos.diff d9bca87496daff6a8b51972dbe0ba48a  openssl-0.9.8h-macos.diff
}
get_win32_patches() {
    # readline
    # this patch comes from http://gpsim.sourceforge.net/gpsimWin32/packages/readline-5.2-20061112-src.zip
    download http://distfiles.minitage.org/public/externals/minitage/patches/readline-5.2-src.diff  a635c45040ffd0c39f46ad6c404f5c85  readline-5.2-src.diff
}

# usage error
usage(){
    echo;echo
    echo "${YELLOW} PyBootStrapper $version:"
    echo "${BLUE}$0 $RED $0 [-o|--offline] [-2.4|-2.5] PREFIX"
    echo "${GREEN}      Will bootstrap python (2.6 by default) into PREFIX $NORMAL"
    echo "${YELLOW}   If you choose offline mode, put you files into PREFIX/downloads $NORMAL"
    echo "${YELLOW}   If you choose to build python2.4 instead of 2.6, add -2.4 to args. $NORMAL"
    echo "${YELLOW}   If you choose to build python2.5 instead of 2.6, add -2.5 to args. $NORMAL"
}

# make a temporary directory and go inside
# $1: the directory
mkdir_and_gointo(){
    local dir="$1"
    if [[ -n "$dir" ]];then
        local destdir="$tmp_dir/$dir"
        if [[ -e "$destdir" ]];then
            rm -rf "$destdir" || die "error deleting bad tmp dir $destdir"
        fi
        mkdir -p "$tmp_dir/$dir" 2> /dev/null || die "cant create dir"
        qpushd "$tmp_dir/$dir"
    else
        die "mkdir_and_gointo: give arg"
    fi
}

set_mac_target() {
    if [[ $UNAME == "Darwin"  ]];then
        LDFLAGS="$LDFLAGS -mmacosx-version-min=10.5.0"
    fi
}

# $1: name for errors NOT SET TO NULL OR SHOOT IN YOUR FEES
# $@ compile opts
cmmi() {
    local myname="$1"
    shift
    compile_opts="$@"
    echo "Running: ./configure $@"
    export CFLAGS=" -fPIC -O3 -I$prefix/include "
    export CPPFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    if [[ $UNAME == 'FreeBSD' ]];then
        export LDFLAGS=" -rpath $prefix/lib -rpath /lib"
    else
        export LDFLAGS=" -Wl,-rpath -Wl,$prefix/lib -Wl,-rpath -Wl,/lib"
    fi
    export LD_RUN_PATH="$prefix"
    set_mac_target
    echo $CFLAGS
    make clean
    ./configure $@ || die "$myname config failed"
    echo "Compiling:"
    make #|| die "$myname compilation failed"
    echo "Installing:"
    make install || die "$myname install failed"
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS LD_RUN_PATH
}

# return the last part from an URL, basically the file name.
# $1: URL
give_filename_from_url() {
    local arg=$1
    local url="$(echo "$arg" |"$SED" -re "s:^((http|ftp)\://.*/)([^/]*)(/*)$:\3:g")"
    if [[ -z "$url" ]];then
        die "Failed to get filename from $arg"
    else
        echo "$url"
    fi
}

compile_bz2() {
    local myfullpath="bz2.tbz2"
    local bz2_cflags="-fpic -fPIC -Wall -Winline -O3  -I. -L. -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib'"
    # check the download is good
    download "$bz2_mirror" "$bz2_md5" "$myfullpath"
    mkdir_and_gointo "bz2"
    tar xzvf "$download_dir/$myfullpath" -C .
    cd *
    set_mac_target
    if [[ $UNAME == 'Darwin' ]];then
        download "$bz2_darwinpatch" "$bz2_darwinpatch_md5" "bz2darwin.patch";
        patch="$download_dir/bz2darwin.patch"
        sed "s|__MacPorts_Compatibility_Version__|1.0|"  $patch\
            | sed "s|__MacPorts_Version__|1.0.4|"\
            | patch -p0
    fi
    make CFLAGS="$bz2_cflags"
    make install PREFIX="$prefix" || die "make install failed"
    # the libbz2 shared library

    if [[ $UNAME != 'Darwin' ]];then
        make  -f Makefile-libbz2_so all || die "Make failed libbz2"
    fi
    for i in libbz2.so.* libbz2.a ;do
        if [[  -e "$i" ]];then
            cp "$i" "$prefix/lib" || die "shared librairies installation failed"
        fi
    done
    cp bzlib.h "$prefix/include" || die "shared include installation failed"
}
compile_zlib() {
    local myfullpath="zlib.tbz2"
    # check the download is good
    download "$zlib_mirror" "$zlib_md5" "$myfullpath"
    mkdir_and_gointo "zlib"
    tar xjvf "$download_dir/$myfullpath" -C .
    cd *
    cmmi  "$myname" --shared --prefix="$prefix" || die "cmmi failed for $myname"
    make test || die "zlib test failed"
}

compile_readline(){
    local myfullpath="readline.tgz"
    # check the download is good
    download "$readline_mirror" "$readline_md5" "$myfullpath"
    download http://distfiles.minitage.org/public/externals/minitage/readline61-001 c642f2e84d820884b0bf9fd176bc6c3f readline61-001
    download http://distfiles.minitage.org/public/externals/minitage/readline61-002 1a76781a1ea734e831588285db7ec9b1 readline61-002
    mkdir_and_gointo "readline"
    tar xzvf "$download_dir/$myfullpath" -C .
    cd *
    patch -Np0 < "$download_dir/readline61-001"
    patch -Np0 < "$download_dir/readline61-002"
    export CFLAGS=" -I$prefix/include  -I$prefix/include/ncurses"
    export CPPFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS=" -Wl,-rpath -Wl,$prefix/lib -Wl,-rpath -Wl,/lib "
    export LD_RUN_PATH="$prefix"
    set_mac_target
    make clean
    ./configure -prefix="$prefix"  || die "$1 config failed"
    echo "Compiling:"
    make || die "$1 compilation failed"

    echo "Installing:"
    make install || die "$1 install failed"

    unset CFLAGS CPPFLAGS LDFLAGS LD_RUN_PATH
}

compile_ncurses(){
    local myfullpath="ncurses.tgz"
    myname=ncurses
    # check the download is good
    download "$ncurses_mirror" "$ncurses_md5" "$myfullpath"
    mkdir_and_gointo "$myname"
    tar xzvf "$download_dir/$myfullpath" -C .
    cd *
    cmmi  "$myname" --enable-const --enable-colorfgbg --enable-echo\
    --with-shared --enable-rpath \
    --with-manpage-format=normal --with-rcs-ids --enable-symlinks \
    $(if [[ $UNAME == 'Darwin' ]];then echo '--without-libtool';fi) \
    --prefix="$prefix" || die "cmmi failed for $myname"
}

compile_openssl(){
    local myfullpath="openssl.tgz" platform="" ldflags=""
    # check the download is good
    download "$openssl_mirror" "$openssl_md5" "$myfullpath"
    mkdir_and_gointo "openssl"
    tar xzvf "$download_dir/$myfullpath" -C .
    ldflags=" -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib'"
    sconfigure="./config"
    cd *
    if [[ $UNAME == 'FreeBSD' ]];then
        platform=""
    fi
    if [[ $UNAME == 'Darwin' ]];then
        ldflags="$ldflags  -mmacosx-version-min=10.5.0"
        if [[ $(uname -r|cut -c1-3  ) == "10." ]];then
            platform="darwin64-x86_64-cc"
        fi 
        sconfigure="./Configure"
    fi
    if [[ $UNAME == 'Darwin' ]];then
        $sconfigure --prefix="$prefix" --openssldir=="$prefix/etc/ssl" shared no-fips "$platform" $ldflags
    else
        $sconfigure --prefix="$prefix" --openssldir=="$prefix/etc/ssl" shared $ldflags no-fips  "$platform"
    fi
    if [[ $UNAME == 'FreeBSD' ]];then
        gsed \
        -e 's|^FIPS_DES_ENC=|#FIPS_DES_ENC=|' \
        -e 's|^FIPS_SHA1_ASM_OBJ=|#FIPS_SHA1_ASM_OBJ=|' \
        -e 's|^SHLIB_EXT=.*$$|SHLIB_EXT=.so.$(SHLIBVER)|' \
        -e 's|fips-1.0||' \
        -e 's|^SHARED_LIBS_LINK_EXTS=.*$$|SHARED_LIBS_LINK_EXTS=.so|' \
        -e 's|^SHLIBDIRS= fips|SHLIBDIRS=|' \
        -i  ./Makefile || die "gsed failed"
    fi
    make depend || die "make depend openssl failed"
    make || die "make openssl failed"
    make install || die "make install openssl failed"
}

compile_python(){
    local myfullpath="python.tbz2"
    # check the download is good
    download "$python_mirror" "$python_md5" "$myfullpath"
    mkdir_and_gointo "python"
    tar xjvf "$download_dir/$myfullpath" -C .
    cd *
    # XXX OSX hack
    CFLAGS="  -I$prefix/include -I$prefix/include/ncurses -I.    $([[ $UNAME == 'Darwin' ]] && echo '-mmacosx-version-min=10.5.0  -D__DARWIN_UNIX03 ')"
    CFLAGS="$CFLAGS   $([[ $UNAME == 'FreeBSD' ]] && echo '-DTHREAD_STACK_SIZE=0x100000')"
    LDFLAGS=" -L$prefix/lib -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib' $([[ $UNAME == 'Darwin' ]] && echo '-mmacosx-version-min=10.5.0')"
    export CFLAGS="$CFLAGS" CPPFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
    export LD_RUN_PATH="$prefix/lib"
    #not using cmmi as i need specific linkings
    ./configure  --prefix="$prefix"   \
    --enable-shared  --with-bz2   --enable-unicode=ucs4 \
    $(if [[ $UNAME == 'Darwin' ]];then echo "--enable-toolbox-glue";fi) \
    $(if [[ $UNAME != CYGWIN* ]];then echo "--with-fpectl";fi) \
    --with-readline --with-zlib \
    OPT="$CFLAGS" \
    CPPFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    --includedir="$prefix/include" \
    --libdir="$prefix/lib"|| die "cmmi failed for python"
    if [[ $UNAME == 'Darwin' ]];then
        cp pyconfig.h pyconfig.h.old
        cat pyconfig.h.old|grep -v  SETPGRP >pyconfig.h
        echo >> pyconfig.h
        echo "#define   SETPGRP_HAVE_ARG 1">> pyconfig.h
        echo >> pyconfig.h
    fi
    make || die "python compilation failed"
    make install || die "python install failed"
    unset CFLAGS CPPFLAGS LDFLAGS OPT LD_RUN_PATH
}

ez_offline() {
    egg="$1"
    ez="$(ls $prefix/bin/easy_install*|tail -n1)"
    "$ez" -H None -f "$download_dir" "$egg" || die "easy install failed for egg"
}

installorupgrade_setuptools(){
    local myfullpath="ez.py"
    # check the download is good
    download "$ez_mirror" "$ez_md5" "$myfullpath"
    qpushd $prefix
    res=$("$python" "$download_dir/$myfullpath")
    qpopd
    res=$(echo $res|$SED -re "s/.*(-U\s*distribute).*/reinstall/g")
    if [[ "$res" == "reinstall" ]];then
       "$python" "$download_dir/$myfullpath" -U Distribute
    fi
    download "$virtualenv_mirror" "$virtualenv_md5"
    if [[ $UNAME == CYGWIN* ]];then
        qpushd $prefix/tmp
        # openssl
        download http://distfiles.minitage.org/public/externals/minitage/patches/virtualenv.win.diff 6c3d9b5f103a380041991d9c0714a73b virtenv.diff
        tar xzvf "$download_dir/virtualenv-1.1.tar.gz"
        cd virtualenv-1.1
        patch -p0<"$download_dir/virtenv.diff"
        "$python" setup.py install
    else
        ez_offline "VirtualEnv"   || die "VirtualEnv installation failed"
    fi
}

compile() {
    local done="$prefix/.compiled$1"
    if [[ ! -f $done ]];then
        "compile_$1" && touch $done
    else
        echo "WARNING: $1 is already compiled (delete '$done' to recompile)."
    fi
}

bootstrap() {
    compile bz2      || die "compile_and_install_bz2 failed"
    compile zlib     || die "compile_and_installzlib failed"
    compile ncurses  || die "compile_and_install ncurses failed"
    compile readline || die "compile_and_install_readline failed"
    compile openssl  || die "compile_and_install_openssl failed"
    compile python   || die "compile_and_install_python failed"
}

main() {
    #if [[ $UNAME == 'Darwin' ]];then
    #    get_macos_patches
    #fi
    bootstrap
    installorupgrade_setuptools || die "install_setuptools failed"
    rm -rf "$tmp_dir"/* &
    echo "Installation is now finnished."
    echo "some cleaning is running in the background and may take a while."
    echo "While it's cleaning, the machine can be a bit slower."
}

create_destination() {
    local cli_dir="$1"
    if [[ -e "$cli_dir" ]];then
        echo "Warning: Directory not empty"
    fi
    mkdir -p "$cli_dir" || die "Cannot create destination directory"
    # absolute path needed for safety
    qpushd "$cli_dir"
    prefix="$(pwd)"
    download_dir="${prefix}/downloads"
    tmp_dir="${prefix}/tmp"
    python="$prefix/bin/python"
    for dir in "$tmp_dir" "$download_dir";do
        if [[ ! -d "$dir" ]];then
            mkdir "$dir" || die "creation of $dir failed"
        fi
    done
    qpopd
}

# parse command line
cli_dir=""
# usage is requested
for arg in $@;do
    # offline mode
    if [[ "$arg" == "-test" ]];then
        test_mode="true"
    elif [[ "$arg" == "--offline" ]];then
        offline="y"
    elif [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]] ;then
        usage
        exit
    elif [[ $arg == "-2.4" ]] || [[ $arg == "--python-2.4" ]];then
        echo "$YELLOW User choosed to Build python-2.4 !$NORMAL"
        sleep 2
        python_mirror="$python24_mirror"
        python_md5="$python24_md5"
    elif [[ $arg == "-2.5" ]] || [[ $arg == "--python-2.5" ]];then
        echo "$YELLOW User choosed to Build python-2.5 !$NORMAL"
        sleep 2
        python_mirror="$python25_mirror"
        python_md5="$python25_md5"
    elif [[ $arg == "-o" ]] || [[ $arg == "--offline" ]];then
        offline="y"
    else
        cli_dir="$arg"
    fi
done

# about to install
if [[ -z "$cli_dir" ]] && [[ ! -n "$test_mode" ]];then
    usage
    die "You must precise the directory to bootstrap to."
else
    if [[ -z "$test_mode" ]];then
        # create_destination will register the $prefix variable !
        create_destination "$cli_dir"
        main "$prefix"
    fi
fi
# vim:set ts=4 sts=4 sw=4 et ai ft=sh tw=0 :
