#!/usr/bin/env bash
cd $(dirname $0)
w=$PWD
for i in "$w" "$w/.." "$w/../.." "$w/../../.." "$w/../../../..";do
    if [[ -f     "${i}/bin/minimerge" ]]\
        || [[ -e "${i}/minilays" ]]\
        || [[ -e "${i}/eggs/cache" ]]\
        || [[ -e "$(ls -1d "${i}/sources/minitage."*|head -n1)" ]];then
    cd "$i"
    w=$PWD
    break
fi
done
command=$1
shift
THIS=minitagetool.sh
ARCHIVES_PATH="${ARCHIVES_PATH:-"$w/snapshots"}"
COMMAND_ARGS=$@
sync_path=${BASE_EGGS:-"${w}/host/home/kiorky/projects/repos/hg.minitage.org/eggs/"}
GIT_URL="git@github.com:minitage"
HTTP_URL="http://github.com/minitage"
sync_minpath=${BASE_EGGS:-"${w}/host/home/kiorky/minitage"}
PYPATH=$w/tools/python
PYB="$w/sources/minitage.shell/PyBootstrapper.sh"
ONLINE="${ONLINE:-""}"
SYNC="$SYNC:-""}"
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
LOGGER="${LOGGER:-"minitagetool"}"
log() {
    echo "${BLUE}${LOGGER}:${NORMAL} $@"
} 
warn() {
    log $(echo "${YELLOW}$@${NORMAL}")
}
blue() {
    log $(echo "${BLUE}$@${NORMAL}")
}
green() {
    log $(echo "${GREEN}$@${NORMAL}")
}
red() {
    log $(echo "${RED}$@${NORMAL}")
}                         
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

qpushd() {
    pushd "$1" 2>&1 >> /dev/null
}
qpopd() {
    popd    2>&1 >> /dev/null
}
minimerge_wrapper() {
    local args="-v"
    if [[ -z $ONLINE ]];then
        args="$args -o"
    fi
    . "$w/bin/activate"
    minimerge $args $@ || die "minimerge $args $@ failed"
    deactivate
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
    local args=""
    if [[ -z $ONLINE ]];then
        args="$args -o"
    fi
    if [[ ! -d "${DOWNLOADS_DIR}" ]];then
        mkdir -p "${DOWNLOADS_DIR}"
    fi
    DOWNLOADS_DIR="$DOWNLOADS_DIR/minitage" "$PYB"  $args "$PYPATH" || die "pybootstrapper failed  !"
}
virtualenv() {
    rm -rf "$w/bin" "$w/include"  "$w/lib"
    markers="fetch_initial_deps|install_pyboostrap|boot_checkout_or_update|virtualenv"
    rm -f $(ls -1a "$w/.com*"|egrep -v "$markers")
    "$PYPATH/bin/virtualenv" --distribute --no-site-packages "$w" || die "virtualenv failed"
    make deploy_minitage
}
deploy_minitage() {
    local skipdeps="$1" make="make"
    if [[ -n $skipdeps ]];then
        make=""
    fi
    $make install_minitage_deps
    install_minitage
    if [[ -n ${SYNC} ]] && [[ -f "$w/bin/minimerge" ]];then
        minimerge_wrapper -s
    fi
    install_minitage_python
}
refresh() {
    if [[ -n ${SYNC} ]];then
        checkout_or_update
    fi
    if [[ -f "$w/.compiled_-virtualenv" ]];then
        deploy_minitage skipdeps
    fi
}
install_minitage() {
    local py="${1:-"${w}"}"
    for i in $minitage_eggs_core;do
        pushd "$w/sources/$i"
        "$py/bin/python" setup.py develop
        popd
    done
    to_cache "$w"
}
to_cache() {
    install_in_cache "zc.buildout<2dev" "$1"
    install_in_cache "zc.buildout>2dev" "$1"
    rm -rvf "$w/eggs/cache/"*minitage* \
        "$DOWNLOADS_DIR/dist/"*minitage* \
        "$DOWNLOADS_DIR/minitage/eggs/"*minitage*
    for i in $minitage_eggs;do
        qpushd "$w/sources/$i"
        develop_only . $1
        qpopd
    done
}
install_minitage_python() {
    local pys="python-2.7 python-2.6 python-2.4"
    for python in $pys;do
        minimerge_wrapper "$python" || warn "$python build failed, skipping"
    done
    #for python in $pys;do
    #    local pyprefix="$w/dependencies/${python}/parts/part"
    #    if [[ -e $pyprefix ]];then
    #        to_cache $pyprefix
    #    fi
    #done
}
die() {
    red $@;exit -1
}
ez_offline() {
    local egg="$1" pyprefix="${2:-$w}" ez=""
    ez="$(ls $pyprefix/bin/easy_install*|tail -n1)"
    if [[ -n $ONLINE ]];then
        "$ez" -f "$fl" "$egg" || die "easy install(online) failed for egg"
    else
        "$ez" -H None -f "$fl" "$egg" || die "easy install (offline) failed for egg"
    fi
}
develop_only() {
    local eggdir="$1" pyprefix="${2:-$w}" py="" online="$ONLINE"
    py="$(ls $pyprefix/bin/python|tail -n1)"
    red "Installing $egg"
    qpushd "$eggdir"
    eggdir="$PWD"
    "$py" setup.py develop -qNH None -f "$fl" || die "develop_only failed for egg: $eggdir"
    local tmp="$PWD/tmp"
    rm -rf "$tmp"
    mkdir "$tmp"
    PYTHONPATH="$tmp" "$py" setup.py develop -qxN -d "$tmp" -S "$tmp"
    rm -rf tmp/eas* tmp/*py tmp/*py{c,o}
    cp -vf tmp/*  "$w/eggs/cache"
    rm -rf "$tmp"
    qpopd
}
install_in_cache() {
    local egg="$1" pyprefix="${2:-$w}" ez="" py="" online="$ONLINE"
    ez="$(ls $pyprefix/bin/easy_install*|tail -n1)"
    py="$(ls $pyprefix/bin/python|tail -n1)"
    if [[ -d $egg ]];then
        rm -rf dist
        "$py" setup.py sdist --formats=zip
        egg="$(ls -1rt $PWD/dist/*zip|tail -n1)"
        online=""
    fi
    red "Installing $egg"
    if [[ -n $ONLINE ]];then
        "$ez" -qmxd "$w/eggs/cache" -f "$fl" "$egg" || die "easy install in cache (online) failed for egg: $egg"
    else
        "$ez" -qmxd "$w/eggs/cache" -H None -f "$fl" "$egg" || die "easy install in cache failed for egg: $egg"
    fi
}
install_minitage_deps() {
    local pyprefix="${1:-$w}"
    for i in $MINITAGE_DEPS;do
        ez_offline "$i" "$pyprefix" || die "cant install egg: $i"
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
        warn "$1 is already done (delete '$sdone' to redo)."
    fi
}
snapshot() {
    local CHRONO=$(date +"%Y-%m-%d-%H-%M-%S")
    cd "$w"
    local f=BASE.txt
    local download=DOWNLOAD.txt
    local projects=PROJECTS.txt
    local db=DB.txt
    local ignoref=IGNORE.txt
    echo > "$f"
    echo > "$ignoref"
    echo > "$download"
    echo > "$projects"
    local projects_dirs=""
    for i in $(ls $w);do
        if [[ -d $i ]];then
            if [[ "$minitage_base_dirs" != *"$i"* ]];then
                projects_dirs="$projects_dirs $i"
            fi
        fi
    done
    local eggs_dirs=""
    for i in $(ls -d eggs/*);do
        if [[ $i != "eggs/cache"* ]];then
            eggs_dirs="$eggs_dirs $i"
        fi
    done
    local excl_regex="^(([^/])+/([^/])+/)(\$|bin|.*pyc|eggs"
    excl_regex="${excl_regex}|develop-eggs|parts|sys"
    excl_regex="${excl_regex}|var|__min.*|\.minitage"
    excl_regex="${excl_regex}|\.downloads|\.installed.cfg"
    excl_regex="${excl_regex}|\.mr\.developer.cfg"
    excl_regex="${excl_regex}|var"
    excl_regex="${excl_regex})"
    local minilays="minilays/(dependencies|cgwb|eggs|plone)"
    find \
        dependencies/ \
        sources/ \
        $projects_dirs\
        $eggs_dirs\
        | egrep $excl_regex\
        >>"$ignoref"
    find eggs/cache\
        | grep  "linux-x86_64.egg" \
        >>"$ignoref"
    find \
        dependencies/ \
        sources/ \
        bfg/cgwb \
        $minilays \
        $eggs_dirs\
        | egrep -v $excl_regex \
        >>"$f"
    find $projects_dirs minilays\
        $projects "$ignoref"\
        | egrep -v $excl_regex \
        | egrep -v "${minilays}">>"$projects"
    find $DOWNLOADS_DIR -type f >> "${download}"
    find eggs/cache/ "$download" \
        | egrep -v "\.pyc" \
        | egrep -v "\.pyo" \
        | grep -v "linux-x86_64.egg" \
        >>"${download}"
    for i in minilays "$f" "$ignoref";do
        echo "$i">>"$f"
    done
    if [[ ! -d "$ARCHIVES_PATH" ]];then
        mkdir -pv "$ARCHIVES_PATH"
    fi
    local sbase="${ARCHIVES_PATH}/minitageoffline-${CHRONO}"
    local snapf="${sbase}-base.tbz2"
    local snapd="${sbase}-downloads.tbz2"
    local snapp="${sbase}-projects.tbz2"
    warn "Archiving minitage in $snapf $snapd $snapp?"
    warn "<C-C> to abort";read
    tar cjvf "$snapf" -T "$f" -X "$ignoref"
    tar cjvf "$snapd" -T "$download" -X "$ignoref"
    tar cjvf "$snapp" -T "$projects" -X "$ignoref"
    red "Produced $snapf $snapd $snapp"
}
safe_check() {
    local pypi=$(egrep "^127\.0\.0\.1.*pypi.python.org" /etc/hosts|wc -l)
    if [[ "$pypi" == "0" ]];then
        if [[ -z ${ONLINE} ]];then
            warn "Did you forget to add to /etc/hosts (<C-C> to abort, <enter to continue> :"
            blue "127.0.0.1 pypi.python.org"
            read
        fi
    fi
}
install_plone_deps() {
    if [[ ! -e $w/zope/plone ]];then
        mkdir -pv "$w/zope/plone"
        mkdir -pv "$w/minilays/plone"
    fi
    cp "$w/dependencies/zlib-1.2/bootstrap.py" "$w/zope/plone"
    cat > "$w/minilays/plone/plone" << EOF
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
    cat > "$w/zope/plone/buildout.cfg" << EOF
[buildout]
versions = versions
parts = part
hooks-directory = \${buildout:directory}/hooks
develop-eggs-directory=../../eggs/develop-eggs
eggs-directory=../../eggs/cache
[versions]
zc.buildout=1.7.1
[part]
recipe = plone.recipe.command
update-command=\${part:command}
command = echo installed
EOF
    minimerge_wrapper plone
}
install_cgwb(){
    CGWB_MINILAY="https://github.com/collective/collective.generic.webbuilder-minilay.git"
    qpushd "$w/minilays"
    if [[ ! -d cgwb ]];then
        git clone "$CGWB_MINILAY" cgwb
    fi
    qpopd
    minimerge_wrapper -v cgwb
    qpushd "$w/bfg/cgwb/src.others"
    rm -rf minitage.paste
    ln -sf "$w/sources/minitage.paste"
    qpopd
}
install_project(){
    minimerge_wrapper --only-dependencies $i
    minimerge_wrapper -NE $1
    minimerge_wrapper -NRv $i
}
fetch_initial_deps() {
    minimerge_wrapper -s
    minimerge_wrapper --fetchonly --only-dependencies all
}
deploy(){
    configure_buildout
    make install_pyboostrap
    make virtualenv
    safe_check
    if [[ -n ${ONLINE} ]];then
        if [[ -n ${SYNC} ]];then
            make fetch_initial_deps
        fi
    fi
    make install_plone_deps
    if [[ -n $ONLINE ]];then
        make install_cgwb
    fi
    for i in ${COMMAND_ARGS};do
        install_project $i
    done
}
eggpush() {
    for i in $sync_eggs;do
        rsync -azv \
            $rexclude \
            "$w/sources/$i/" \
            "$sync_path/$i/"
    done
}
push() {
    eggpush
}
sync() {
    for i in eggs dependencies eggs/cache minilays;do
        if [[ ! -e "$w/$i" ]];then
            mkdir "$w/$i"
        fi
    done
    for i in $sync_eggs;do
        rsync -azv \
            --delete \
            --include='*/*/bin' \
            $rexclude \
            "$sync_path/$i/" \
            "$w/sources/$i/"
    done
    #rsync -azv $rexclude --delete --delete-excluded \
        rsync -azv $rexclude \
        --exclude=cache \
        --exclude=cache.local \
        "$sync_minpath/eggs/" "$w/eggs/"
    #rsync -azv $rexclude --delete --delete-excluded \
        rsync -azv $rexclude \
        $sync_minpath/dependencies/ $w/dependencies/
    for i in eggs dependencies;do
        rsync -azv "${sync_minpath}/minilays/$i/" "$w/minilays/$i/"
    done
    install_minitage
    install_minitage_python
}
cgwb(){
    minimerge_wrapper cgwb
    cd "$w/bfg/cgwb"
    ./l.sh
}
do_mount(){
    cd "$w"
    echo "enter root password"
    su -c "route del default"
    [[ ! -d host ]] && mkdir host
    sshfs host:/ host
}
selfupgrade() {
    local do_sync="$SYNC"  online="$ONLINE"
    export ONLINE="y" SYNC="y"
    refresh
    install_plone_deps
    minimerge_wrapper -NRv cgwb
    export SYNC="$do_sync" ONLINE="$online"
    qpopd

}
install_tool() {
    rm -f  "$w/$THIS" "$w/bin/$THIS"
    if [[! -d "$w/bin" ]];then
        mkdir -pv "$w/bin"
    fi
    ln -sf "$w/sources/minitage.shell/$THIS" "$w/$THIS"
    ln -sf "$w/sources/minitage.shell/$THIS" "$w/bin/$THIS"
}
checkout_or_update() {
    for d in sources eggs/cache;do
        if [[ ! -d "$d" ]];then
            mkdir -pv "$d"
        fi
    done
    qpushd sources
    for i in $(echo $minitage_eggs minitage.shell);do
        if [[ ! -d $i ]];then
            git clone "${GIT_URL}/$i" || git clone "${HTTP_URL}/$i"
        fi
        qpushd "$i"
        git pull || die "problem updating $i"
        qpopd
    done
    qpopd
    if [[ -e "$w/bfg/cgwb" ]];then
        qpushd "$w/bfg/cgwb"
        git pull
        if [[ -f "bin/develop" ]];then
            qpushd src.others/collective.generic.skel
            git pull
            qpopd
        fi
    fi
    install_tool
}
# wrapper to be used only once at bootstrap time
boot_checkout_or_update() {
    checkout_or_update
}
bootstrap() {
    local make="make"
    for i in $@;do
        if [[ $i == "sync" ]];then
            make=""
        fi
    done
    $make boot_checkout_or_update
    ONLINE="TRUE" SYNC="TRUE" "$w/$THIS" deploy
}
usage() {
    echo "        --------------------"
    warn "        | MINITAGE  HELPER |"
    echo "        --------------------"
    blue "$script_usage"
    echo
    red "To make a minitage installation usable in offline mode / fixed mode,"
    red "You need to setup things like that:"
    echo
    red "First, deploy a special minitage for snapshoting  the install"
    red "Then install your project minilay & run the minimerge dance"
    warn "WARNING: it touches ~/.buildout/default.cfg to set the local download cache"
    green "  cd minitage_root"
    green "  wget -O $THIS https://raw.github.com/minitage/minitage.shell/master/$THIS"
    green "  chmod +x $THIS"
    echo
    red "Installing the base minitage dependencies $(warn "-> NEED TO HAVE INTERNET & GIT")"
    green "  $w/$THIS bootstrap $(blue "# take a coffee...")"
    echo
    red "Installing your a project and then making a snapshot $(warn "-> NEED TO HAVE INTERNET")"
    green "  cd minitage/minilays && git clone minilay"
    green "  bin/minimerge <project>"
    green "  $w/$THIS snapshot"
    echo
    red "This produce snapshots in the current directory:"
    green "  - $(blue "${ARCHIVES_PATH}/<minitageoffline-CHRONO-base.tar.gz>")$(green "      : Minitage base code")"
    green "  - $(blue "${ARCHIVES_PATH}/<minitageoffline-CHRONO-downloads.tar.gz>")$(green " : Download & egg cache")"
    green "  - $(blue "${ARCHIVES_PATH}/<minitageoffline-CHRONO-projects.tar.gz>")$(green " : Download & egg cache")"
    echo
    red "Upgrade minitage"
    green "     $w/$THIS selfupgrade"
    echo
    red "Launch cgwb"
    green "     $w/$THIS cgwb"
    echo
    red "ReDeploy a snapshot with:"
    warn "WARNING: it touches ~/.buildout/default.cfg to set the local download cache"
    green "     tar xzvf <minitageoffline-CHRONO-base.tar.gz>"
    green "     tar xzvf <minitageoffline-CHRONO-downloads.tar.gz>"
    green "     tar xzvf <minitageoffline-CHRONO-projects.tar.gz>"
    green "     $w/$THIS deploy <project> [... <project3>]$(blue "# install an offlinizable-minitage in the current directory")"
    echo
    red "checkout_or_update && eggpush && mount && sync && refresh && push targets are to sync code between"
    red "my (kiorky) test virtual machine & host, "
    red "read it to see if it is useful in your case"
}
script_usage="$0 cgwb|selfupgrade|refresh|bootstrap|checkout_or_update|deploy|snapshot|eggpush|mount|sync|push"
case $command in
    eggpush|bootstrap|push|deploy|snapshot|sync|refresh|checkout_or_update|selfupgrade|cgwb) $command ${COMMAND_ARGS} ;;
    mount) do_${command} ${COMMAND_ARGS};;
    help|--help|-h|usage) usage ;;
    *) echo $script_usage ;;
esac
# vim:set et sts=4 ts=4 tw=80:
