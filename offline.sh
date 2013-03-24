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
    echo > "$f"
    find \
        dependencies/ \
        zope/\
        eggs/boost-python-1     \
        eggs/pil-1.1.7          \
        eggs/pycairo-1          \
        eggs/py-libxml2-2.7     \
        eggs/py-libxslt-1.1     \
        eggs/pyqt-4             \
        eggs/sip-4              \
        | egrep -v "dependencies/[^/]+/bin"    \
        | egrep -v "dependencies/[^/]+/eggs"    \
        | egrep -v "dependencies/[^/]+/develop-eggs"    \
        | egrep -v "dependencies/[^/]+/parts"    \
        | egrep -v "dependencies/[^/]+/sys"      \
        | egrep -v "dependencies/[^/]+/var"      \
        | egrep -v "dependencies/[^/]+/__min.*"      \
        | egrep -v "dependencies/[^/]+/.minitage"\
        | egrep -v "dependencies/[^/]+/.downloads"\
        | egrep -v "dependencies/[^/]+/.installed.cfg"\
        | grep -v ".pyc" \
        >>"$f"
    find downloads -type f >> "$f"
    find eggs/cache/ \
        | egrep "py-?.?\.egg" \
        | egrep "py-?.?-linux-x86_64" \
        | grep -v ".pyc" \
        >>"$f"
    echo "$f">>"$f"
    #echo "Archivhing? <C-C> to abort";read
    #tar cjvf minitageoffline-${CHRONO}.tbz2 \
    #    sources downloads \
    #    sources downloads \
    #    archive.sh deploy.sh .git
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
    minimerge -ov python-2.7 python-2.6 python-2.4
    for python in python-2.7 python-2.6 python-2.4;do
        install_minitage_deps $w/dependencies/${python}/parts/part
        install_minitage      $w/dependencies/${python}/parts/part 
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
    make configure_buildout
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
    for i in $sync_eggs;do
        rsync -azv \
            --delete \
            $rexclude \
            $sync_path/$i/ \
            $w/sources/$i/
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
case $1 in
    mount) do_$1 ;;
    eggpush|push|deploy|archive|sync) $1 ;;
    *) echo "$a mount|eggpush|deploy|archive|sync|push";;
esac
# vim:set et sts=4 ts=4 tw=80:
