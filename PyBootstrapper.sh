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


# filter commandline
# set there offline mode if any
for arg in $@;do
	if [[ $arg == "-o" ]] || [[ $arg == "--offline" ]];then
		offline="y"
		shift
	fi
done

# mac osx hack ;)
MD5SUM="$(which md5sum)"
if [[ -f $(which md5) ]];then
	MD5SUM="md5 -q"
fi

prefix="$1"

#  to have bzip2 everywhere
export PATH="$prefix/bin:$prefix:/sbin:$PATH"
echo $(which bzip2)
download_dir="${prefix}/downloads"
tmp_dir="${prefix}/tmp"



#another macosx hack
if [[ -f $(which curl) ]];then
	wget="$(which curl) -a -o"
# freebsd
elif [[ -f $(which fetch) ]];then
	wget="$(which fetch) -spra -o"
elif [[ -f $(which wget) ]];then
	wget="/usr/bin/wget -c -O"
fi
#echo $wget;read
python="$prefix/bin/python2.4"
ez="$prefix/bin/easy_install"

readline_mirror="http://85.25.128.62/gentoo/distfiles/readline-5.2.tar.gz"
readline_mirror2="ftp://gentoo.imj.fr/pub/gentoo/distfiles/readline-5.2.tar.gz"
readline_mirror1="ftp://ftp.cwru.edu/pub/bash/readline-5.2.tar.gz"
readline_md5="e39331f32ad14009b9ff49cc10c5e751"

bz2_mirror="http://85.25.128.62/gentoo/distfiles/bzip2-1.0.4.tar.gz"
bz2_mirror="ftp://gentoo.imj.fr/pub/gentoo/distfiles/bzip2-1.0.4.tar.gz"
bz2_md5="fc310b254f6ba5fbb5da018f04533688"

zlib_mirror1="http://www.gzip.org/zlib/zlib-1.2.3.tar.bz2"
zlib_mirror2="http://www.zlib.net/zlib-1.2.3.tar.bz2"
zlib_md5="dee233bf288ee795ac96a98cc2e369b6"


ncurses_mirror="http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.6.tar.gz"
ncurses_md5="b6593abe1089d6aab1551c105c9300e3"

python_mirror="http://www.python.org/ftp/python/2.4.4/Python-2.4.4.tar.bz2"
python_md5="0ba90c79175c017101100ebf5978e906"

ez_setup_mirror="http://peak.telecommunity.com/dist/ez_setup.py"
ez_setup_md5="699931a7578f5ed386bea58165c3854b"

# get some libs into env :)
version="0.1"

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
# download in installdir/downloads
# $1: download url. The last part of the url will be the filename by default
# $3: filename
# $2: filename's md5
#dont put "/" at the end of the url or provide a filename
download(){
	local md5="$2" myfile="$3" url="$1" mydest=""
	if [[ -n $md5 ]] && [[ -n $url ]];then
		if [[ ! -e "$download_dir" ]];then
			mkdir -p "$download_dir" || die "cant create download dir: $download_dir"
		fi

		[[ -z $myfile ]] && myfile=${url//*\/}
		mydest="$download_dir/$myfile"
		# offline mode
		if [[ ! -f $mydest ]] && [[ -n $offline ]];then
			die "file $mydest does not exists!!!"
		fi
		if [[ -f "$mydest" ]];then
			file_md5="$($MD5SUM $mydest|awk '{print $1}')"
		fi
		if [[ -z $offline ]] && [[ "$md5" != "$file_md5" ]];then
			$wget "$mydest" "$url"
			file_md5="$($MD5SUM $mydest|awk '{print $1}')"
		fi
	fi
	echo "$mydest"
}
# usage error
usage(){
	echo;echo
	echo "${YELLOW}Makina BootStrapper $version:"
	echo "${BLUE}$0 $RED $0 [-o|--offline] PREFIX"
	echo "${GREEN}      Will bootstrap python into $prefix"
	echo "${GREEN}      Give an abosolute pathname $prefix"
}
mkdir_and_gointo(){
	if [[ -n $1 ]];then
		local destdir="$tmp_dir/$1"
		if [[ -e "$destdir" ]];then
			echo
			rm -rf "$destdir"||die "error deleting bad tmp dir $destdir"
		fi
		mkdir -p "$tmp_dir/$1" || die "cant create dir"
		pushd "$tmp_dir/$1"
	else
		die "mkdir_and_gointo: give arg"
	fi
}
# $1: name for errors NOT SET TO NULL OR SHOOT IN YOUR FEES
# $@ compile opts
cmmi(){
	local myname="$1"
	shift
	compile_opts="$@"
	echo "Running: ./configure $@"
	export CFLAGS=" -I$prefix/usr/include"
	export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS"
	export LDFLAGS=" -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib'"
	make clean
	./configure $@ || die "$1 config failed"
	echo "Compiling:"
	make || die "$1 compilation failed"
	echo "Installing:"
	make install || die "$1 install failed"
}
compile_bz2() {
	local myname="bzip2" myver="1.0.4" md5=$bz2_md5
	local myfullpath="$(download "$bz2_mirror"  "$bz2_md5")"
	local mycompiledir="$myname-$myver"
	# check the download is good
	file_md5="$($MD5SUM $myfullpath|awk '{print $1}')"
	[[ "$md5" != "$file_md5" ]] && echo "WARNING:! md5 for $myfullpath failed : $md5 != $file_md5 !"
	[[ ! -e "$myfullpath" ]] && die "$myfullpath"
	mkdir_and_gointo "$myname"
	tar xzvf "$myfullpath" -C .
	cd "$mycompiledir"
	#macosx is a borked system
	#make CFLAGS="-fpic -fPIC -Wall -Winline -O3 -g \"\$(BIGFILES)\" -I. -L.  -Wl,-rpath='$prefix/lib' -Wl,-rpath='/lib'" -f Makefile-libbz2_so || die "$myname shared lib compilation failed"
	make CFLAGS="-fpic -fPIC -Wall -Winline -O3  -I. -L.  -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib'"
	for i in libbz2.so.* libbz2.a ;do
		if [[  -e $i ]];then
			cp $i $prefix/lib || die "shared librairies installation failed"
		fi
	done
	cp bzlib.h $prefix/include || die "shared include installation failed"
	make install PREFIX="$prefix" || die "make install failed"
}
compile_readline(){
	local myname="readline" myver="5.2" md5="$zlib_md5"
	local myfullpath="$(download "$readline_mirror"  "$readline_md5")"
	local mycompiledir="$myname-$myver"
	# check the download is good
	file_md5="$($MD5SUM $myfullpath|awk '{print $1}')"
	[[ "$md5" != "$file_md5" ]] && echo "WARNING:! md5 for $myfullpath failed : $md5 != $file_md5 !"
	[[ ! -e "$myfullpath" ]] && die "$myfullpath"
	mkdir_and_gointo "$myname"
	tar xzvf "$myfullpath" -C .
	cd "$mycompiledir"
	export CFLAGS=" -I$prefix/include  -I$prefix/include/ncurses"
	export CPPFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS"
	export LDFLAGS=" -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib'"
	make clean
	./configure -prefix="$prefix"  || die "$1 config failed"
	echo "Compiling:"
	make || die "$1 compilation failed"
	echo "Installing:"
	make install || die "$1 install failed"
}
compile_ncurses(){
	local myname="ncurses" myver="5.6" md5="$ncurses_md5"
	local myfullpath="$(download "$ncurses_mirror"  "$ncurses_md5")"
	local mycompiledir="$myname-$myver"
	# check the download is good
	file_md5="$($MD5SUM $myfullpath|awk '{print $1}')"
	[[ "$md5" != "$file_md5" ]] && echo "WARNING:! md5 for $myfullpath failed : $md5 != $file_md5 !"
	[[ ! -e "$myfullpath" ]] && die "$myfullpath"
	mkdir_and_gointo "$myname"
	tar xzvf "$myfullpath" -C .
	cd "$mycompiledir"
	cmmi  "$myname"  --enable-const --enable-colorfgbg --enable-echo  \
	--with-manpage-format=normal --with-rcs-ids --enable-symlinks     \
	--disable-termcap --with-shared  $(if [[ $(uname) != 'Darwin' ]];then echo '--with-libtool';fi) \
	--prefix="$prefix" || die "cmmi failed for $myname"
}
compile_zlib(){
	local myname="zlib" myver="1.2.3" md5="$zlib_md5"
	local myfullpath="$(download "$zlib_mirror2"  "$zlib_md5")"
	local mycompiledir="$myname-$myver"
	# check the download is good
	file_md5="$($MD5SUM $myfullpath|awk '{print $1}')"
	[[ "$md5" != "$file_md5" ]] && echo "WARNING:! md5 for $myfullpath failed : $md5 != $file_md5 !"
	[[ ! -e "$myfullpath" ]] && die "$myfullpath"
    mkdir_and_gointo "$myname"
    tar xjvf "$myfullpath" -C .
	cd "$mycompiledir"
	cmmi  "$myname" --prefix="$prefix" --shared || die "cmmi failed for $myname"
	make test || die "zlib test failed"
}
compile_python(){
	local myname="Python" myver="2.4.4" python="$python_md5"
	local myfullpath="$(download "$python_mirror"  "$python_md5")"
	local mycompiledir="$myname-$myver"
	# XXX OSX hack
	CFLAGS="  -I$prefix/include -I$prefix/include/ncurses -I.    $([[ $(uname) == 'Darwin' ]] && echo '-mmacosx-version-min=10.5.0  -D__DARWIN_UNIX03 ')"
	LDFLAGS=" -Wl,-rpath -Wl,'$prefix/lib' -Wl,-rpath -Wl,'/lib' $([[ $(uname) == 'Darwin' ]] && echo '-mmacosx-version-min=10.5.0')"
	export CFLAGS="$CFLAGS" CPPFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
	file_md5="$($MD5SUM $myfullpath|awk '{print $1}')"
	[[ "$md5" != "$file_md5" ]] && echo "WARNING:! md5 for $myfullpath failed : $md5 != $file_md5 !"
	# check the download is good
	[[ ! -e "$myfullpath" ]] && die "$myfullpath"
	mkdir_and_gointo "$myname"
	tar xjvf "$myfullpath" -C .
	cd "$mycompiledir"
	#not using cmmi as i need specific linkings
	./configure "$myname"  --prefix="$prefix"   \
	--enable-shared --with-fpectl --with-bz2 \
	$(if [[ $(uname) == 'Darwin' ]];then echo "--enable-toolbox-glue";fi) \
	--with-readline --with-zlib --with-ncurses \
	OPT="$CFLAGS" CPPFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
	--includedir="$prefix/include" \
	--libdir="$prefix/lib"|| die "cmmi faileccd for $myname"
	echo "Compiling:"
	#make LDFLAGS="$LDFLAGS" || die "$myname compilation failed"
	make || die "$myname compilation failed"
	echo "Installing:"
	make install || die "$myname install failed"
	#make test || die "tests failed" # long, uncomment as your needs
	unset CFLAGS CPPFLAGS LDFLAGS
}
installorupgrade_setuptools(){
	local myfullpath="$(download "$ez_setup_mirror"  "$ez_setup_md5")" md5="$ez_setup_md5"
	# check the download is good
	[[ ! -e "$myfullpath" ]] && die "$myfullpath"
	file_md5="$($MD5SUM $myfullpath|awk '{print $1}')"
	[[ "$md5" != "$file_md5" ]] && echo "WARNING:! md5 for $myfullpath failed : $md5 != $file_md5 !"
	res=$("$python" "$myfullpath"  )
	res=$(echo $res|sed -re "s/.*(-U\s*setuptools).*/reinstall/g")
	if [[ "$res" == "reinstall" ]];then
		"$python" "$myfullpath" -U setuptools
	fi
	"$ez" "zc.buildout"         || die "zc.buildout installation failed"
	"$ez" "ZopeSkel"            || die "ZopeSkel installation failed"
	"$ez" "VirtualEnv"          || die "VirtualEnv installation failed"
}
bootstrap(){
	for i in "$prefix" "$prefix/lib" \
		"$prefix/bin" "$prefix/include" ;do
		if [[ ! -e "$i" ]];then
			mkdir "$i"|| die "base dirs creation failed for: $i"
		fi
	done
	compile_bz2	                || die "compile_and_install_bz2 failed"
	compile_zlib                || die "compile_and_installzlib failed"
	compile_ncurses             || die "compile_and_install ncurses failed"
	compile_readline            || die "compile_and_install_readline failed"
	compile_python              || die  "compile_and_install_python failed"
}
main(){
	bootstrap
	installorupgrade_setuptools || die "install_setuptools failed"
	rm -rf "$tmp_dir"/* &
	echo "Installation is now finnished."
	echo "some cleaning is running in the background and may take a while."
	echo "While it's cleaning, the machine can be a bit slowier."
}
if [[ -z "$prefix" ]];then
	usage
	exit -1
else
	main
fi
# vim:set ts=4 sts=4 sw=4 et ai ft=sh tw=80 :
