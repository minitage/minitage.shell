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
version="0.4"
offline=""

# filter commandline
# set there offline mode if any
for arg in $@;do
    if [[ $arg == "-o" ]] || [[ $arg == "--offline" ]];then
        offline="y"
        shift
    fi
done

MD5SUM="$(which md5sum)"
if [[ -f $(which md5 2>/dev/null) ]];then
    MD5SUM="md5 -q"
fi

# export PATH to have bzip2 and our perso binaries everywhere
export PATH="$prefix/bin:$prefix:/sbin:$PATH"

#another macosx hack
if [[ -f $(which curl) ]];then
    wget="$(which curl) -a -o"
    # freebsd
elif [[ -f $(which fetch) ]];then
    wget="$(which fetch) -spra -o"
elif [[ -f $(which wget) ]];then
    wget="/usr/bin/wget -c -O"
fi

gentoo_mirror="http://85.25.128.62"
#gentoo_mirror="ftp://gentoo.imj.fr/pub"
gentoo_mirror="$gentoo_mirror"

gnu_mirror="http://ftp.gnu.org/pub/gnu"

readline_mirror="$gentoo_mirror/gentoo/distfiles/readline-5.2.tar.gz"
readline_md5="e39331f32ad14009b9ff49cc10c5e751"

bz2_mirror="$gentoo_mirror/gentoo/distfiles/bzip2-1.0.4.tar.gz"
bz2_md5="fc310b254f6ba5fbb5da018f04533688"

zlib_mirror="$gentoo_mirror/gentoo/distfiles/zlib-1.2.3.tar.bz2"
zlib_md5="dee233bf288ee795ac96a98cc2e369b6"

ncurses_mirror="$gnu_mirror/ncurses/ncurses-5.6.tar.gz"
ncurses_md5="b6593abe1089d6aab1551c105c9300e3"

python_mirror="http://www.python.org/ftp/python/2.4.4/Python-2.4.4.tar.bz2"
python_md5="0ba90c79175c017101100ebf5978e906"

openssl_mirror="http://www.openssl.org/source/openssl-0.9.7m.tar.gz"
openssl_md5="74a4d1b87e1e6e1ec95dbe58cb4c5b9a"

ez_mirror="http://peak.telecommunity.com/dist/ez_setup.py"
ez_md5="94ce3ba3f5933e3915e999c26da9563b"

virtualenv_mirror="http://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.0.tar.gz"
virtualenv_md5="fb86aabdfc2033612b936cf08ad811ec"

hg_mirror="http://hg.intevation.org/files/mercurial-1.0.tar.gz"
hg_md5="9f8dd7fa6f8886f77be9b923f008504c"
 
zc_buildout_mirror="http://pypi.python.org/packages/source/z/zc.buildout/zc.buildout-1.0.1.tar.gz"
zc_buildout_md5="438748533cdf043791c98799ed4b8cd3"

# pretty term colors
GREEN=$'\e[32;01m'
YELLOW=$'\e[33;01m'
RED=$'\e[31;01m'
BLUE=$'\e[34;01m'
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
    if [[ -n "$md5" ]] && [[ -n "$url" ]];then
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
            die "$myfile doesn't match the md5 "$md5" ($file_md5)"
        fi
        echo "Downloaded $mydest"
    fi
}

# usage error
usage(){
    echo;echo
    echo "${YELLOW} PyBootStrapper $version:"
    echo "${BLUE}$0 $RED $0 [-o|--offline] PREFIX"
    echo "${GREEN}      Will bootstrap python into PREFIX"
    echo "${YELLOW}   If you choose offline mode, put you files into PREFIX/downloads"
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

# $1: name for errors NOT SET TO NULL OR SHOOT IN YOUR FEES
# $@ compile opts
cmmi() {
    local myname="$1"
    shift
    compile_opts="$@"
    echo "Running: ./configure $@"
    export CFLAGS=" -I$prefix/usr/include"
    export CPPFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="-Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib'"
    export LD_RUN_PATH="$prefix"
    make clean
    ./configure $@ || die "$1 config failed"
    echo "Compiling:"
    make || die "$1 compilation failed"
    echo "Installing:"
    make install || die "$1 install failed"
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
    make CFLAGS="$bz2_cflags"
    make install PREFIX="$prefix" || die "make install failed"
    for i in libbz2.so.* libbz2.a ;do
        if [[  -e "$i" ]];then
            cp "$i" "$prefix/lib" || die "shared librairies installation failed"
        fi
    done
    cp bzlib.h "$prefix/include" || die "shared include installation failed"
}

compile_zlib(){
    local myfullpath="zlib.tbz2"
    # check the download is good
    download "$zlib_mirror" "$zlib_md5" "$myfullpath"
    mkdir_and_gointo "zlib"
    tar xjvf "$download_dir/$myfullpath" -C .
    cd *
    cmmi  "$myname" --prefix="$prefix" --shared || die "cmmi failed for $myname"
    make test || die "zlib test failed"
}

compile_readline(){
    local myfullpath="readline.tgz"
    # check the download is good
    download "$readline_mirror" "$readline_md5" "$myfullpath"
    mkdir_and_gointo "readline"
    tar xzvf "$download_dir/$myfullpath" -C .
    cd *
    export CFLAGS=" -I$prefix/include  -I$prefix/include/ncurses"
    export CPPFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS=" -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib'"
    export LD_RUN_PATH="$prefix"
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
    # check the download is good
    download "$ncurses_mirror" "$ncurses_md5" "$myfullpath"
    mkdir_and_gointo "ncurses"
    tar xzvf "$download_dir/$myfullpath" -C .
    cd *
    cmmi  "$myname"  --enable-const --enable-colorfgbg --enable-echo  \
    --with-manpage-format=normal --with-rcs-ids --enable-symlinks     \
    --disable-termcap --with-shared \
    $(if [[ $(uname) != 'Darwin' ]];then echo '--with-libtool';fi) \
    --prefix="$prefix" || die "cmmi failed for $myname"
}

compile_openssl(){
    local myfullpath="openssl.tgz" platform=""
    # check the download is good
    download "$openssl_mirror" "$openssl_md5" "$myfullpath"
    mkdir_and_gointo "openssl"
    tar xzvf "$download_dir/$myfullpath" -C .
    cd *
    if [[ $(uname) == 'FreeBSD' ]];then
        platform='FreeBSD-elf';
    fi
    if [[ $(uname) == 'Darwin' ]];then
        platform='darwin-i386-cc -mmacosx-version-min=10.5.0' ;
    fi
    ./config --prefix="$prefix" shared ${flags:cflags} ${flags:ldflags} no-fips "$platform"
    if [[ $(uname) == 'FreeBSD' ]];then
        gsed \
        -e 's|^FIPS_DES_ENC=|#FIPS_DES_ENC=|' \
        -e 's|^FIPS_SHA1_ASM_OBJ=|#FIPS_SHA1_ASM_OBJ=|' \
        -e 's|^SHLIB_EXT=.*$$|SHLIB_EXT=.so.$(SHLIBVER)|' \
        -e 's|fips-1.0||' \
        -e 's|^SHARED_LIBS_LINK_EXTS=.*$$|SHARED_LIBS_LINK_EXTS=.so|' \
        -e 's|^SHLIBDIRS= fips|SHLIBDIRS=|' \
        -i  ./Makefile || die "gsed failed"
    fi
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
    CFLAGS="  -I$prefix/include -I$prefix/include/ncurses -I.    $([[ $(uname) == 'Darwin' ]] && echo '-mmacosx-version-min=10.5.0  -D__DARWIN_UNIX03 ')"
    LDFLAGS=" -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib' $([[ $(uname) == 'Darwin' ]] && echo '-mmacosx-version-min=10.5.0')"
    export CFLAGS="$CFLAGS" CPPFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
    export LD_RUN_PATH="$prefix/lib"
    #not using cmmi as i need specific linkings
    ./configure  --prefix="$prefix"   \
    --enable-shared --with-fpectl --with-bz2 \
    $(if [[ $(uname) == 'Darwin' ]];then echo "--enable-toolbox-glue";fi) \
    --with-readline --with-zlib --with-ncurses \
    OPT="$CFLAGS" \
    CPPFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    --includedir="$prefix/include" \
    --libdir="$prefix/lib"|| die "cmmi failed for python"
    make || die "python compilation failed"
    make install || die "python install failed"
    unset CFLAGS CPPFLAGS LDFLAGS OPT LD_RUN_PATH
}

ez_offline() {
    egg="$1"
    "$ez" -H None -f "$download_dir" "$egg" || die "easy install failed for egg"
}

installorupgrade_setuptools(){
    local myfullpath="ez.py"
    # check the download is good
    download "$ez_mirror" "$ez_md5" "$myfullpath"
    res=$("$python" "$download_dir/$myfullpath")
    res=$(echo $res|sed -re "s/.*(-U\s*setuptools).*/reinstall/g")
    if [[ "$res" == "reinstall" ]];then
        "$python" "$download_dir/$myfullpath" -U setuptools
    fi
    download "$virtualenv_mirror" "$virtualenv_md5"
    ez_offline "VirtualEnv"   || die "VirtualEnv installation failed"
    download "$hg_mirror" "$hg_md5"
    ez_offline "Mercurial"   || die "VirtualEnv installation failed" 
    download "$zc_buildout_mirror" "$zc_buildout_md5"
    ez_offline  "zc.buildout" || die "zc.buildout installation failed"
}

bootstrap() {
    compile_bz2	     || die "compile_and_install_bz2 failed"
    compile_zlib     || die "compile_and_installzlib failed"
    compile_ncurses  || die "compile_and_install ncurses failed"
    compile_readline || die "compile_and_install_readline failed"
    compile_openssl  || die "compile_and_install_openssl failed"
    compile_python   || die "compile_and_install_python failed"
}

main() {
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
    python="$prefix/bin/python2.4"
    ez="$prefix/bin/easy_install" 
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
        shift
    elif [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]] ;then
        usage
        exit
    else
        cli_dir="$arg"
    fi
done

# about to install
if [[ ! -d "$cli_dir" ]] && [[ ! -n "$test_mode" ]];then
    usage
    die "You must precise the directory to bootstrap to."
else
    if [[ -z "$test_mode" ]];then
        # create_destination will register the $prefix variable !
        create_destination "$cli_dir"
        main "$prefix"
    fi
fi
# vim:set ts=4 sts=4 sw=4 et ai ft=sh tw=80 :
