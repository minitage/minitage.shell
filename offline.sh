#!/usr/bin/env bash
cd $(dirname $0)
w=$PWD
sync_path=${BASE_EGGS:-"${w}/host/home/kiorky/projects/repos/hg.minitage.org/eggs/"}
sync_minpath=${BASE_EGGS:-"${w}/host/home/kiorky/minitage"}
sync_eggs="
    minitage.recipe.du
    minitage.paste
    minitage.core
    minitage.recipe.common
    minitage.recipe.scripts
    minitage.recipe.fetch
    minitage.recipe.egg
    minitage.recipe.cmmi
    minitage.recipe
    buildout.minitagificator
"
PYPATH=$w/tools/python
PYB="$w/minitage.shell/PyBootstrapper.sh"
MINITAGE_DEPS="
    iniparse ordereddict
    Paste PasteDeploy PasteScript
    Cheetah
    zc.buildout
"
minitage_eggs="
    buildout.minitagificator
    minitage.paste
    minitage.core
    minitage.recipe.common
    minitage.recipe.cmmi
    minitage.recipe.du
    minitage.recipe.egg
    minitage.recipe.scripts
    minitage.recipe.fetch
    minitage.recipe
"
rexclude="
    --exclude=*tar.gz
    --exclude=.installed.cfg
    --exclude=.mr.developer.cfg
    --exclude=*tgz
    --exclude=*tar.bz
    --exclude=*tar.bz2
    --exclude=*tbz2
    --exclude=eggs
    --exclude=parts
    --exclude=bin
    --exclude=.minitage
    --exclude=a
    --exclude=*.new
    --exclude=PyQt-mac-gpl-4.9.4
    --exclude=__minitage*
    --exclude=.installed.cfg
    --exclude=.download
    --exclude=sys
    --exclude=pyc
    --exclude=*pyc
    --exclude=*egg-info
"
minitage_base_dirs="
bin 
cpan 
downloads 
etc 
include  
logs      
sources  
dependencies  
eggs       
host  
lib      
minilays  
tools"
# pretty term colors
GREEN=$'\e[32;01m'
YELLOW=$'\e[33;01m'
RED=$'\e[31;01m'
BLUE=$'\e[34;01m'
NORMAL=$'\e[0m'
warn() {
    echo "${YELLOW}$@${NORMAL}"
}
blue() {
    echo "${BLUE}$@${NORMAL}"
}
green() {
    echo "${GREEN}$@${NORMAL}"
}
red() {
    echo "${RED}$@${NORMAL}"
}
qpushd() {
    pushd "$1" 2>&1 >> /dev/null
}
qpopd() {
    popd    2>&1 >> /dev/null
}
configure_buildout() {
if [[ ! -e ~/.buildout ]];then
    mkdir ~/.buildout
fi
if [[ ! -e ~/.buildout/default.cfg ]];then
cat > ~/.buildout/default.cfg << EOF
[buildout]
download-directory = $w/downloads
download-cache =     $w/downloads
EOF
else
    nb=$(grep "$w/downloads" ~/.buildout/default.cfg | wc -l)
    if [[ "$nb" == "0" ]];then
cat >> ~/.buildout/default.cfg << EOF
download-directory = $w/downloads
download-cache =     $w/downloads
EOF
fi
fi
}
install_pyboostrap() {
    DOWNLOADS_DIR=$w/downloads/minitage $PYB -o $PYPATH
}
virtualenv() {
    $PYPATH/bin/virtualenv --distribute --no-site-packages $w
}
install_minitage() {
    local py="${1:-"${w}"}"
    for i in $minitage_eggs;do
        pushd $w/sources/$i
            $py/bin/python setup.py develop
        popd
    done
}
die() {
    echo $@;exit -1
}
ez_offline() {
    local egg="$1" fl="" pyprefix="${2:-$w}"
    fl="$fl ${w}/downloads/dist"
    fl="$fl ${w}/downloads/minitage/eggs"
    ez="$(ls $pyprefix/bin/easy_install*|tail -n1)"
    "$ez" -H None -f "$fl" "$egg" || die "easy install failed for egg"
}
install_minitage_deps() {
    pyprefix="${1:-$w}"
    for i in $MINITAGE_DEPS;do
        ez_offline $i $pyprefix || die "cant install egg: $i"
    done
}
make() {
    local done="$w/.compiled$1"
    if [[ ! -f $done ]];then
        "$1" && touch $done
    else
        echo "WARNING: $1 is already done (delete '$done' to redo)."
    fi
}
archive() {
    local CHRONO=$(date +"%Y-%m-%d-%H-%M-%S")
    cd $(dirname $0)
    f=CONTENT.txt
    ignoref=IGNORE.txt
    echo > "$f"
    echo > "$ignoref"
    projects_dirs=""
    for i in $(ls $w);do
        if [[ -d $i ]];then
            if [[ "$minitage_base_dirs" != *"$i"* ]];then
                projects_dirs="$projects_dirs $i"
            fi
        fi
    done
    eggs_dirs=""
    for i in $(ls -d eggs/*);do
        if [[ $i != "eggs/cache"* ]];then
            eggs_dirs="$eggs_dirs $i"
        fi
    done
    excl_regex="^(([^/])+/([^/])+/)(\$|bin|.*pyc|eggs"
    excl_regex="${excl_regex}|develop-eggs|parts|sys"
    excl_regex="${excl_regex}|var|__min.*|\.minitage"
    excl_regex="${excl_regex}|\.downloads|\.installed.cfg"
    excl_regex="${excl_regex}|\.mr\.developer.cfg)"
    find \
        dependencies/ \
        sources/ \
        $projects_dirs\
        $eggs_dirs\
        | egrep $excl_regex\
        >>"$ignoref"
    find \
        dependencies/ \
        sources/ \
        $projects_dirs\
        $eggs_dirs\
        | egrep -v $excl_regex \
        >>"$f"
    find downloads -type f >> "$f"
    find eggs/cache/ \
        | egrep "py-?.?\.egg" \
        | egrep "py-?.?-linux-x86_64" \
        | grep -v ".pyc" \
        >>"$f"
    for i in minilays $f $ignoref;do
        echo "$i">>"$f"
    done
    local archivef="$w/minitageoffline-${CHRONO}.tbz2"
    warn "Archivhing current minitage in $archivef?"
    warn "<C-C> to abort";read
    tar cjvf "$archivef" -T "$f" -X "$ignoref"
    red "Produced $archivef"
}
safe_check() {
     pypi=$(egrep "^127\.0\.0\.1.*pypi.python.org" /etc/hosts|wc -l)
    if [[ "$pypi" == "0" ]];then
        warn "Did you forget to add to /etc/hosts:"
        blue "127.0.0.1 pypi.python.org"
        read
    fi
}
install_minitage_python() {
    . $w/bin/activate
    local pys="python-2.7 python-2.6 python-2.4"
    for python in $pys;do
        minimerge -ov $python || warn "$python build failed, skipping"
    done
    for python in $pys;do
        local pyprefix="$w/dependencies/${python}/parts/part"
        if [[ -e $pyprefix ]];then
            install_minitage_deps $pyprefix
            install_minitage      $pyprefix
        fi
    done
}
install_plone_deps() {
    if [[ ! -e $w/zope/plone ]];then
        mkdir -pv $w/zope/plone
        mkdir -pv $w/minilays/plone
        cp $w/eggs/pil-1.1.7/bootstrap.py $w/zope/plone
cat > $w/minilays/plone/plone << EOF
[minibuild]
dependencies= libxml2-2.7 libxslt-1.1 py-libxml2-2.7 py-libxslt-1.1 pil-1.1.7 libiconv-1.12 python-2.7 git-1.7 subversion-1.7 openldap-2.4
install_method=buildout
src_uri=/dev/null
src_type=git
category=zope
homepage=
description=
buildout_config=buildout.cfg
EOF
cat > $w/zope/plone/buildout.cfg << EOF
[buildout]
versions = versions
parts = part
hooks-directory = \${buildout:directory}/hooks
develop-eggs-directory=../../eggs/develop-eggs
eggs-directory=../../eggs/cache
[versions]
[part]
recipe = plone.recipe.command
update-command=\${part:command}
command = echo installed
EOF
    fi
    minimerge -ov plone
}
deploy(){
    configure_buildout
    make install_pyboostrap
    make virtualenv
    make install_minitage_deps
    make install_minitage
    safe_check
    make install_minitage_python
    make install_plone_deps
}
eggpush() {
    for i in $sync_eggs;do
        rsync -azv \
            $rexclude \
            $w/sources/$i/ \
            $sync_path/$i/
    done
}
push() {
    eggpush
}
sync() {
    for i in eggs dependencies eggs/cache minilays;do
        if [[ ! -e $w/$i ]];then
            mkdir $w/$i
        fi
    done
    for i in $sync_eggs;do
        rsync -azv \
            --delete \
            --include='*/*/bin' \
            $rexclude \
            $sync_path/$i/ \
            $w/sources/$i/
    done
    #rsync -azv $rexclude --delete --delete-excluded \
    rsync -azv $rexclude \
        --exclude=cache \
        --exclude=cache.local \
        $sync_minpath/eggs/ $w/eggs/
    #rsync -azv $rexclude --delete --delete-excluded \
    rsync -azv $rexclude \
        $sync_minpath/dependencies/ $w/dependencies/
    for i in eggs dependencies;do
        rsync -azv ${sync_minpath}/minilays/$i/ $w/minilays/$i/
    done
    install_minitage
}
do_mount(){
    cd $(dirname $0)
    echo "enter root password"
    su -c "route del default"
    [[ ! -d host ]] && mkdir host
    sshfs host:/ host
}
usage() {
    warn "          MINITAGE OFFLINE HELPER"
    echo
    blue "$script_usage"
    echo
    red "To make a minitage installation usable in offline mode"
    red "You need to setup things like that:"
    green "     cd minitage_root"
    green "     mkdir -pv sources"
    green "     cd sources"
    green "     for i in $(echo $minitage_eggs minitage.shell);do"
    green "         git clone git@github.com:minitage/\$i"
    green "     done"
    green "     cd .."
    green "     ln -s sources/minitage.shell/offline.sh"
    echo
    red "To prepare an offline minitage installation, "
    red "Deploy on a special minitage to snapshot the install"
    red "Then install your project minilay & run the minimerge dance"
    warn "WARNING: it touches ~/.buildout/default.cfg to set the local download cache"
    green "     ./offline deploy # install an offlinizable-minitage in the current directory"
    green "     cd minitage/minilays"
    green "     git clone minilay"
    green "     bin/minimerge <project>"
    red "This produce an archive in the current directory:"
    green "     <minitageoffline-CHRONO.tar.gz> # (called later as archive.tgz)"
    echo
    red "ReDeploy a snapshop with:"
    warn "WARNING: it touches ~/.buildout/default.cfg to set the local download cache"
    green "     tar xzvf archive.tgz"
    green "     ./offline deploy"
    green "     bin/minimerge <project>"
    echo
    warn "eggpush && mount && sync & push targets are to sync code between"
    warn "my (kiorky) test virtual machine & host, "
    warn "read it to see if it is useful in your case"
}
script_usage="$0 deploy|archive|eggpush|mount|sync|push"
case $1 in
    eggpush|push|deploy|archive|sync) $1 ;;
    mount) do_$1 ;;
    help|--help|-h|usage) usage ;;
    *) echo $script_usage ;;
esac
# vim:set et sts=4 ts=4 tw=80:
