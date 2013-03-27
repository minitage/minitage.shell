#!/usr/bin/env bash
cd $(dirname $0)
w=$PWD
command=$1
shift
COMMAND_ARGS=$@
sync_path=${BASE_EGGS:-"${w}/host/home/kiorky/projects/repos/hg.minitage.org/eggs/"}
sync_minpath=${BASE_EGGS:-"${w}/host/home/kiorky/minitage"}

PYPATH=$w/tools/python
PYB="$w/sources/minitage.shell/PyBootstrapper.sh"
ONLINE=""
DO_SYNC=""
MINITAGE_DEPS="
    iniparse
    ordereddict
    Cheetah
    Paste
    PasteDeploy
    PasteScript
"
minitage_eggs_recipes="
    minitage.recipe.common
    minitage.recipe.cmmi
    minitage.recipe.du
    minitage.recipe.egg
    minitage.recipe.scripts
    minitage.recipe.fetch
    minitage.recipe
    buildout.minitagificator
"
minitage_eggs_core="
    minitage.paste
    minitage.core
"
minitage_eggs="
    $minitage_eggs_core
    $minitage_eggs_recipes
"
sync_eggs="
    $minitage_eggs
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
DOWNLOADS_DIR="$w/downloads"
fl="$fl $DOWNLOADS_DIR/dist"
fl="$fl $DOWNLOADS_DIR/minitage/eggs"
fl="$fl $w/eggs/cache"
GREEN=$'\e[32;01m'
YELLOW=$'\e[33;01m'
RED=$'\e[31;01m'
BLUE=$'\e[34;01m'
NORMAL=$'\e[0m'
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

minimerge_wrapper() {
    local args="-o -v"
    if [[ -n $ONLINE ]];then
        args=""
    fi
    echo "minimerge $args"

}
configure_buildout() {
    if [[ ! -e ~/.buildout ]];then
        mkdir ~/.buildout
    fi
    if [[ ! -e ~/.buildout/default.cfg ]];then
    cat > ~/.buildout/default.cfg << EOF
[buildout]
download-directory = $DOWNLOADS_DIR
download-cache =     $DOWNLOADS_DIR
EOF
    else
        nb=$(grep "$w/downloads" ~/.buildout/default.cfg | wc -l)
        if [[ "$nb" == "0" ]];then
            cat >> ~/.buildout/default.cfg << EOF
download-directory = $DOWNLOADS_DIR
download-cache =     $DOWNLOADS_DIR
EOF
        fi
    fi
}
install_pyboostrap() {

    DOWNLOADS_DIR=$DOWNLOADS_DIR/minitage $PYB $PYPATH
}
virtualenv() {
    $PYPATH/bin/virtualenv --distribute --no-site-packages $w
}
refresh() {
    install_minitage_deps
    install_minitage
    install_minitage_python
}
install_minitage() {
    local py="${1:-"${w}"}"
    for i in $minitage_eggs_core;do
        pushd $w/sources/$i
            $py/bin/python setup.py develop
        popd
    done
}
install_minitage_python() {
    . $w/bin/activate
    local pys="python-2.7 python-2.6 python-2.4"
    for python in $pys;do
        minimerge_wrapper $python || warn "$python build failed, skipping"
    done
    rm -rvf "$w/eggs/cache/"*minitage* \
        "$DOWNLOADS_DIR/dist/"*minitage* \
        "$DOWNLOADS_DIR/minitage/eggs/"*minitage*
    for python in $pys;do
        local pyprefix="$w/dependencies/${python}/parts/part"
        if [[ -e $pyprefix ]];then
            install_in_cache "zc.buildout<2dev" $pyprefix
            install_in_cache "zc.buildout>2dev" $pyprefix
            for i in $minitage_eggs;do
                qpushd $w/sources/$i
                install_in_cache . $pyprefix
                qpopd
            done
        fi
    done
}
die() {
    echo $@;exit -1
}
ez_offline() {
    local egg="$1" pyprefix="${2:-$w}" ez=""
    ez="$(ls $pyprefix/bin/easy_install*|tail -n1)"
    if [[ -n $ONLINE ]];then
        "$ez" -f "$fl" "$egg" || die "easy install failed for egg"
    else
        "$ez" -H None -f "$fl" "$egg" || die "easy install failed for egg"
    fi
}
install_in_cache() {
    local egg="$1" pyprefix="${2:-$w}" ez="" py="" online="$ONLINE"
    ez="$(ls $pyprefix/bin/easy_install*|tail -n1)"
    py="$(ls $pyprefix/bin/python|tail -n1)"
    if [[ -d $egg ]];then
        rm -rf dist
        $py setup.py sdist --formats=zip
        egg="$(ls -1rt $PWD/dist/*zip|tail -n1)"
        online=""
    fi
    red "Installing $egg"
    if [[ -n $ONLINE ]];then
        "$ez" -qmxd $w/eggs/cache -H None -f "$fl" "$egg" || die "easy install in cache failed for egg: $egg"
    else
        "$ez" -qmxd $w/eggs/cache -f "$fl" "$egg" || die "easy install in cache failed for egg: $egg"
    fi
}
install_minitage_deps() {
    local pyprefix="${1:-$w}"
    for i in $MINITAGE_DEPS;do
        ez_offline $i $pyprefix || die "cant install egg: $i"
    done
}
make() {
    local sdone="$w/.compiled_"
    for i in $@;do
        sdone="${sdone}-${i}"
    done
    if [[ ! -f $sdone ]];then
        "$1" && touch $sdone
    else
        echo "WARNING: $1 is already done (delete '$sdone' to redo)."
    fi
}
archive() {
    local CHRONO=$(date +"%Y-%m-%d-%H-%M-%S")
    cd $(dirname $0)
    f=BASE.txt
    download=DOWNLOAD.txt
    db=DB.txt
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
    excl_regex="${excl_regex}|var)"
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
    find $DOWNLOADS_DIR -type f >> "${download}"
    find eggs/cache/ $download \
        | egrep "py-?.?\.egg" \
        | egrep "py-?.?-linux-x86_64" \
        | grep -v ".pyc" \
        >>"${download}"
    for i in minilays $f $db $ignoref;do
        echo "$i">>"$f"
    done
    local archivef="$w/archives/minitageoffline-${CHRONO}-base.tbz2"
    local archived="$w/archives/minitageoffline-${CHRONO}-downloads.tbz2"
    warn "Archivhing current minitage in $archivef $archived?"
    warn "<C-C> to abort";read
    tar cjvf "$archivef" -T "$f" -X "$ignoref"
    tar cjvf "$archived" -T "$download" -X "$ignoref"
    red "Produced $archivef $archived"
}
safe_check() {
     pypi=$(egrep "^127\.0\.0\.1.*pypi.python.org" /etc/hosts|wc -l)
    if [[ "$pypi" == "0" ]];then
        warn "Did you forget to add to /etc/hosts (<C-C> to abort, <enter to continue> :"
        blue "127.0.0.1 pypi.python.org"
        read
    fi
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
    minimerge_wrapper plone
}

install_project(){
    . $W/bin/activate
    minimerge_wrapper -NE $1
    minimerge_wrapper     $i
}
deploy(){
    configure_buildout
    make install_pyboostrap
    make virtualenv
    make install_minitage_deps
    make install_minitage
    safe_check
    if [[ -n ${DO_SYNC} ]];then
        minimerge_wrapper -s
        minimerge_wrapper --fetchonly --only-dependencies all
    fi
    make install_minitage_python
    make install_plone_deps
    for i in ${COMMAND_ARGS};do
        install_project $i
    done
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
    install_minitage_python
}
do_mount(){
    cd $(dirname $0)
    echo "enter root password"
    su -c "route del default"
    [[ ! -d host ]] && mkdir host
    sshfs host:/ host
}
checkout_or_update() {
    if [[ ! -d sources ]];then
        mkdir -pv sources
    fi
    qpushd sources
    for i in $(echo $minitage_eggs minitage.shell);do
        if [[ ! -d $i ]];then
            git clone git@github.com:minitage/$i
        fi
        qpushd $i
        git pull || die "problem updating $i"
        qpopd
    done
    qpopd
    rm offline.sh -f
    ln -sf sources/minitage.shell/offline.sh offline.sh
}
bootstrap() {
    checkout_or_update
    ONLINE=TRUE DO_SYNC=TRUE ./offline.sh deploy
}
usage() {
    echo "        ---------------------------"
    warn "        | MINITAGE OFFLINE HELPER |"
    echo "        ---------------------------"
    blue "$script_usage"
    echo
    red "To make a minitage installation usable in offline mode / fixed mode,"
    red "You need to setup things like that:"
    echo
    red "First, deploy a special minitage for snapshoting  the install"
    red "Then install your project minilay & run the minimerge dance"
    warn "WARNING: it touches ~/.buildout/default.cfg to set the local download cache"
    green "  cd minitage_root"
    green "  wget -O offline.sh https://raw.github.com/minitage/minitage.shell/master/offline.sh"
    green "  chmod +x offline.sh"
    echo
    red "Installing the base minitage dependencies $(warn "-> NEED TO HAVE INTERNET & GIT")"
    green "  ./offline.sh bootstrap"
    echo
    red "Installing your a project and then making a snapshot $(warn "-> NEED TO HAVE INTERNET")"
    green "  cd minitage/minilays && git clone minilay"
    green "  bin/minimerge <project>"
    green "  ./offline archive"
    echo
    red "This produce archives in the current directory:"
    green "  - $(blue "<minitageoffline-CHRONO-base.tar.gz>")$(green "      : Minitage base code")"
    green "  - $(blue "<minitageoffline-CHRONO-downloads.tar.gz>")$(green " : Download & egg cache")"
    echo
    red "ReDeploy a snapshot with:"
    warn "WARNING: it touches ~/.buildout/default.cfg to set the local download cache"
    green "     tar xzvf <minitageoffline-CHRONO-base.tar.gz>"
    green "     tar xzvf <minitageoffline-CHRONO-downloads.tar.gz>"
    green "     ./offline deploy <project> [... <project3>]$(blue "# install an offlinizable-minitage in the current directory")"
    echo
    red "checkout_or_update && eggpush && mount && sync && refresh && push targets are to sync code between"
    red "my (kiorky) test virtual machine & host, "
    red "read it to see if it is useful in your case"
}
script_usage="$0 refresh|bootstrap|checkout_or_update|deploy|archive|eggpush|mount|sync|push"
case $command in
    eggpush|bootstrap|push|deploy|archive|sync|refresh|checkout_or_update) $command ;;
    mount) do_${command} ;;
    help|--help|-h|usage) usage ;;
    *) echo $script_usage ;;
esac
# vim:set et sts=4 ts=4 tw=80:
