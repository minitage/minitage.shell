#!/usr/bin/env bash
LAUNCH_DIR=$PWD
cd $(dirname $0)
w=$PWD
minsearch() {
    local ret=$(ls -1d "${1}/sources/minitage."* 2>/dev/null)
    echo $ret|head -n1
}
for i in "$w" "$w/.." "$w/../.." "$w/../../.." "$w/../../../..";do
    if [[ -e "${i}/minilays/dependencies" ]]\
        && [[ -e "${i}/minilays/eggs" ]];then
        cd "$i"
        w=$PWD
        break
    else
        if [[ -f     "${i}/bin/minimerge" ]]\
            || [[ -e "${i}/eggs/cache" ]]\
            || [[ -e "$(minsearch ${i})" ]] ;then
            cd "$i"
            w=$PWD
            break
        fi
    fi
done
command=$1
shift
THIS=minitagetool.sh
ARCHIVES_PATH="${ARCHIVES_PATH:-"$w/snapshots"}"
COMMAND_ARGS=$@
CGWB_MINILAY="https://github.com/collective/collective.generic.webbuilder-minilay.git"
sync_path=${BASE_EGGS:-"${w}/host/home/kiorky/minitage/sources/"}
SSH_URL="git@github.com:minitage"
GITP_URL="git://github.com/minitage"
HTTPS_URL="https://github.com/minitage"
HTTP_URL="http://github.com/minitage"
DS="$w/eggs/cache/distribute_setup.py"
GIT_URLS="
    $SSH_URL
    $GITP_URL
    $HTTPS_URL
    $HTTP_URL

"
sync_minpath=${BASE_EGGS:-"${w}/host/home/kiorky/minitage"}
ez_mirror="http://python-distribute.org/distribute_setup.py"
PYPATH="$w/tools/python"
# search for old installs
if [[ ! -e "$w/tools/" ]];then
    mkdir -pv "$w/tools/"
fi
PYPATHS="$w/tools"
if [[ -d "$HOME/tools" ]];then
    PYPATHS="$PYPATHS $HOME/tools"
fi
for i in $(ls -drt $(for j in $PYPATHS;do echo "$j"/*;done) 2>/dev/null);do
    if [[ -e "$i/.compiledpython" ]];then
        PYPATH="$i"
        break
    fi
done
UNAME=$(uname)
UNAME_R=$(uname -r)
PYB="$w/sources/minitage.shell/PyBootstrapper.sh"
if [[ "$ONLINE" == "n" ]];then
    ONLINE=""
else
    ONLINE="y"
fi
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
minitage
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
snapshots
host
lib
minilays
tools"

# pretty term colors
DOWNLOADS_DIR="$w/downloads"
fl="$fl $DOWNLOADS_DIR/dist"
fl="$fl $DOWNLOADS_DIR/minitage/eggs"
fl="$fl $w/eggs/cache"
if [[ -f $(which gsed 2>&1) ]];then
    SED="$(which gsed)"
elif [[ $(uname) == "Darwin" ]];then
    SED="$(which sed)"
else
    SED="$(which sed)"
fi
if [[ $(uname) == "Darwin" ]];then
    SED_RE="$SED -E"
    SED_IRE="$SED -iE"
else
    SED_RE="$SED -re"
    SED_IRE="$SED -ire"
fi
GREEN=$'\e[32;01m'
YELLOW=$'\e[33;01m'
RED=$'\e[31;01m'
BLUE=$'\e[34;01m'
NORMAL=$'\e[0m'
LOGGER="${LOGGER:-"minitagetool"}"
log() {
    echo "${BLUE}${LOGGER}:${NORMAL} $@"
}
syellow() {
    echo "${YELLOW}$@${NORMAL}"
}
warn() {
    log $(echo "${YELLOW}$@${NORMAL}")
}
sblue() {
    echo "${BLUE}$@${NORMAL}"
}
blue() {
    log $(echo "${BLUE}$@${NORMAL}")
}
sgreen() {
    echo "${GREEN}$@${NORMAL}"
}
green() {
    log $(echo "${GREEN}$@${NORMAL}")
}
sred() {
    echo "${RED}$@${NORMAL}"
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

add_paths() {
    if [[ "$UNAME" == "Darwin" ]];then
        if  [[ ! "$PATH" == */usr/X11/bin* ]];then
            syellow "adding /usr/X11/bin to path"
            export PATH=$PATH:/usr/X11/bin
        fi
    fi
}
add_paths

qpushd() {
    pushd "$1" 2>&1 >> /dev/null
}
qpopd() {
    popd    2>&1 >> /dev/null
}
minimerge_wrapper() {
    local args="-v"
    configure_buildout
    if [[ -z $ONLINE ]];then
        args="$args -o"
    fi
    . "$w/bin/activate"
    minimerge $args $@ || die "minimerge $args $@ failed"
    deactivate
}
configure_buildout() {
    dcfg="$HOME/.buildout/default.cfg"
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
    ${SED_IRE}\
        "s:^download-directory.*:download-directory=${DOWNLOADS_DIR}:g" \
        "$dcfg"
    ${SED_IRE} \
        "s:^download-cache.*:download-cache=${DOWNLOADS_DIR}:g" \
        "$dcfg"
    nb=$(grep  $DOWNLOADS_DIR "$dcfg" | wc -l)
    if [[ "$nb" == "0" ]];then
        cat >> "$dcfg" << EOF
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
    DOWNLOADS_DIR="$DOWNLOADS_DIR/minitage" "$PYB" $args "$PYPATH" || die "pybootstrapper failed !"
}

install_virtualenv() {
    green "Making a new virtualenv"
    rm -rf "$w/bin" "$w/include"  "$w/lib"
    "$PYPATH/bin/virtualenv" --distribute --no-site-packages "$w" || die "virtualenv failed"
    install_minitage_deps
    install_tool
}


deploy_minitage() {
    green "Deploying minitage"
    local do_step="do_step"
    install_minitage
    if [[ -n $ONLINE ]] && [[ -n ${SYNC} ]];then
        minimerge_wrapper -s
        do_step fetch_initial_deps
    fi
    install_minitage_python
}

refresh() {
    if [[ -n ${SYNC} ]];then
        checkout_or_update
    fi
}

install_minitage() {
    green "Deploying minitage core dependencies"
    local py="${1:-"${w}"}"
    for i in $minitage_eggs_core;do
        pushd "$w/sources/$i"
        "$py/bin/python" setup.py develop
        popd
    done
    to_cache "$w"
}

to_cache() {
    green "Deploying minitage to buildout caches"
    install_in_cache "zc.buildout<2dev" "$1"
    install_in_cache "zc.buildout>2dev" "$1"
    rm -rvf "$w/eggs/cache/"*minitag*link \
        "$w/eggs/cache/"*minitag*egg \
        "$DOWNLOADS_DIR/dist/"*minitag* \
        "$DOWNLOADS_DIR/minitage/eggs/"*minitag*
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
    red "Installing $eggdir"
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

get_step_marker() {
    local sdone="$w/.compiled_" sdonem="$sdone"
    for i in $@;do
        sdone="${sdone}-${i}"
    done
    if [[ "$sdone" != "$sdonem" ]];then
        echo $sdone
    fi
}

is_done() {
    marker="$(get_step_marker $@)"
    if [[ -f "$marker" ]];then
        echo done
    fi
}

do_step() {
    local marker="$(get_step_marker $@)"
    if [[ ! -f $marker ]];then
        green "run: $1"
        "$1" && touch $marker
    else
        warn "$1 is already done (delete '$marker' to redo)."
    fi
}

snapshot() {
    green "Running snapshot"
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
    selected_projects=""
    for i in $COMMAND_ARGS;do
        if [[ -d $i ]];then
            selected_projects="$selected_projects $i"
        else
            for j in $(ls $w);do
                if [[ -d "$j/$i" ]];then
                    selected_projects="$selected_projects $j/$i"
                fi
            done
        fi
    done
    for i in $(ls $w);do
        if [[ -d $i ]];then
            if [[ "$minitage_base_dirs" != *"$i"* ]];then
                for j in $(ls -d "$i/"*);do
                    if [[ "${selected_projects}" == *"$j"* ]];then
                        projects_dirs="$projects_dirs $j"
                    fi
                done
            fi
        fi
    done
    #echo "$selected_projects / $projects_dirs";exit -1
    local eggs_dirs=""
    for i in $(ls -d eggs/*);do
        if [[ $i != "eggs/cache"* ]];then
            eggs_dirs="$eggs_dirs $i"
        fi
    done
    local excl_regex="^("
    excl_regex="${excl_regex}(snapshots[/])|"
    excl_regex="${excl_regex}((([^/])+/([^/])+/)"
    excl_regex="${excl_regex}(\$|bin|.*pyc|eggs"
    excl_regex="${excl_regex}|develop-eggs|parts|sys"
    excl_regex="${excl_regex}|var|__min.*|\.minitage"
    excl_regex="${excl_regex}|\.downloads|\.installed.cfg"
    excl_regex="${excl_regex}|\.mr\.developer.cfg"
    excl_regex="${excl_regex}|var))"
    excl_regex="${excl_regex})"
    local minilaysre="minilays/(dependencies|cgwb|eggs|plone)"
    local minilays=$(ls -d minilays/{dependencies,cgwb,eggs,plone})
    if [[ -n $selected_projects ]];then
        find \
            dependencies/ \
            sources/ \
            $projects_dirs\
            $eggs_dirs\
            | egrep $excl_regex\
            >>"$ignoref"
    else
        find \
            dependencies/ \
            sources/ \
            $eggs_dirs\
            | egrep $excl_regex\
            >>"$ignoref"
    fi
    find eggs/cache\
        | grep  "linux-x86_64.egg" \
        >>"$ignoref"
    find  \
        dependencies/ \
        sources/ \
        bfg/cgwb \
        $minilays \
        $eggs_dirs\
        | egrep -v $excl_regex \
        >>"$f"
    echo eggs/pil-1.1.7/.downloads >> "$f"
    if [[ -n $selected_projects ]];then
        find $projects_dirs minilays\
            $projects "$ignoref"\
            | egrep -v $excl_regex \
            | egrep -v ${minilaysre}>>"$projects"
    fi
    find ${DOWNLOADS_DIR//${w}/.} -type f >> "${download}"
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
    local msg="Archiving minitage in $snapf"
    if [[ -z $NODOWNLOAD ]];then
        local msg="$msg $snapd"
    fi
    if [[ -n $selected_projects ]];then
        local msg="$msg $snapp"
    fi
    local msg="$msg ?"
    green "$msg"
    warn "<C-C> to abort";read
    tar cjvf "$snapf" -T "$f" -X "$ignoref"
    if [[ -z $NODOWNLOAD ]];then
        tar cjvf "$snapd" -T "$download" -X "$ignoref"
    fi
    if [[ -n $selected_projects ]];then
        tar cjvf "$snapp" -T "$projects" -X "$ignoref"
    fi
    msg="Produced $snapf"
    if [[ -z $NODOWNLOAD ]];then
        msg="$msg $snapd"
    fi
    if [[ -n $selected_projects ]];then
        msg="$msg $snapp"
    fi
    red $msg
}

download_ez() {
    $wget "$DS" "$ez_mirror"
}
find_ds() {
    local ds=$(find "$DS" "$w/downloads/minitage/distribute_setup.py" -name distribute_setup.py 2>/dev/null|head -n1)
    if [[ ! -e "$ds" ]];then
        if [[ -n $ONLINE  ]];then
            download_ez
            local ds=$(find "$DS" "$w/downloads/minitage/distribute_setup.py" -name distribute_setup.py 2>/dev/null|head -n1)
        fi
    fi
    if [[ ! -e "$ds" ]];then
        local ds=$(find  "$PYPATH/downloads"  -name distribute_setup.py 2>/dev/null|head -n1)
    fi
    if [[ ! -e "$ds" ]];then
        local ds=$(find  "$w/downloads"  -name distribute_setup.py 2>/dev/null|head -n1)
    fi
    if [[ ! -e "$ds" ]];then
        local ds=$(find "$w" -name distribute_setup.py 2>/dev/null|head -n1)
    fi
    echo $ds
}

safe_check() {
    green "Safe check"
    local pypi=$(egrep "^127\.0\.0\.1.*pypi.python.org" /etc/hosts|wc -l)
    local ds="$(find_ds)"
    if [[ -e "$ds" ]];then
        if [[ -n $ONLINE  ]];then
            if [[ $(grep "0.7b" "$DS" | wc -l) == "0" ]];then
                warn "Upgrading to last distribute_setup>0.7"
                download_ez
                local ds=$(find "$DS" "$w/downloads/minitage/distribute_setup.py" -name distribute_setup.py 2>/dev/null|head -n1)
            fi
        fi
    fi
    if [[ ! -e $DOWNLOADS_DIR ]];then
        mkdir -pv $DOWNLOADS_DIR
    fi
    if [[ -z ${ONLINE} ]];then
        if [[ ! -e "$ds" ]];then
            die "distribute_setup.py not found"
        fi
        if [[ ! -e "$DS" ]];then
            ln -sfv "$ds" "$DS"
        fi
    fi
    if [[ "$pypi" == "0" ]];then
        if [[ -z ${ONLINE} ]];then
            warn "Did you forget to add to /etc/hosts (<C-C> to abort, <enter to continue> :"
            blue "127.0.0.1 pypi.python.org"
            read
        fi
    fi
}

install_plone_deps() {
    green "Installing plone dependencies"
    if [[ ! -e $w/zope/plone ]];then
        mkdir -pv "$w/zope/plone"
        mkdir -pv "$w/minilays/plone"
    fi
    cp "$w/dependencies/zlib-1.2/bootstrap.py" "$w/zope/plone"
    cat > "$w/minilays/plone/plone" << EOF
[minibuild]
dependencies= libxml2-2.7 libxslt-1.1 py-libxml2-2.7 py-libxslt-1.1 pil-1.1.7 libiconv-1.12 python-2.7 git-1 subversion-1.7 openldap-2.4
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

install_cgwb() {
    green "Installing cgwb"
    qpushd "$w/minilays"
    if [[ ! -d cgwb ]] && [[ -n "$ONLINE" ]];then
        git clone "$CGWB_MINILAY" cgwb
    fi
    qpopd
    minimerge_wrapper --only-dependencies cgwb
    minimerge_wrapper -NRv cgwb
    qpushd "$w/bfg/cgwb/src.others"
    rm -rf minitage.paste
    ln -sf "$w/sources/minitage.paste"
    qpopd
}

install_project() {
    green "Installing project : $1"
    minimerge_wrapper --only-dependencies $i
    minimerge_wrapper -NE $1
    minimerge_wrapper -aNRv $i
}

fetch_initial_deps() {
    green "Fetch initial dependencies"
    if [[ ! -e "$w/minilays/dependencies/zlib"* ]];then
        minimerge_wrapper -s
    fi
    minimerge_wrapper --fetchonly --only-dependencies all
}

have_python() {
    local ret=""
    for marker in .compiledinstalldone .compiledpython;do
        if [[ -e $PYPATH/$marker ]];then
            ret="true"
        fi
    done
    echo $ret
}

offlinedeploy() {
    green "Running $THIS in offline mode"
    ONLINE="" deploy $@
}

ensure_last_distribute() {
    # upgrade to last distribute>0.7 if online
    if [[ -n $ONLINE ]];then
        if [[ $("$w/bin/easy_install" --version|awk '{print $2}'|sed -re "s/0.6.*/match/") == "match" ]];then
            red "Upgrading distribute"
            "$w/bin/easy_install" -U "distribute>=0.7"
        fi
    fi 
}

deploy() {
    green "Running deploy procedure"
    local cargs="${@:-"${COMMAND_ARGS}"}"
    local vdo_step="do_step" mbase="do_step"
    configure_buildout
    do_step boot_checkout_or_update
    # if python has gone, just redo projects
    if [[ -z "$(have_python)" ]];then
        install_pyboostrap
        vdo_step=""
    fi
    if [[ -z "$vdo_step" ]] || [[ -n "$MINITAGEBASE" ]];then
        mbase=""
    fi
    if [[ ! -f "$w/bin/minimerge" ]];then
        mbase=""
    fi
    $vdo_step install_virtualenv
    ensure_last_distribute
    safe_check
    $mbase deploy_minitage
    ensure_last_distribute
    $mbase install_plone_deps
    ensure_last_distribute
    for i in ${cargs};do
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
    green "Synchonnising minitage code base"
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
    SKIPCHECKOUTS="y" selfupgrade
}
install_cgwb_wrapper() {
    if [[ -n $ONLINE ]];then
        install_cgwb
    fi
}

cgwb() {
    do_step install_cgwb_wrapper
    green "Launching cgwb"
    cd "$w/bfg/cgwb"
    ./l.sh
}

do_mount() {
    cd "$w"
    echo "enter root password"
    su -c "route del default"
    [[ ! -d host ]] && mkdir host
    sshfs host:/ host
}

breakp() {
    red "here";read
}

do_selfupgrade() {
    MINITAGEBASE="y" deploy
}

selfupgrade() {
    green "Upgrading minitage"
    export ONLINE="y" SYNC="y"
    if [[ -z ${SKIPCHECKOUTS} ]];then
        refresh
    fi
    cd "$LAUNCH_DIR"
    ONLINE="y" SYNC="y" "$0" do_selfupgrade ${COMMAND_ARGS}

}

install_tool() {
    green "Install minitagetool"
    rm -f  "$w/$THIS" "$w/bin/$THIS"
    if [[ ! -d "$w/bin" ]];then
        mkdir -pv "$w/bin"
    fi
    ln -sf "$w/sources/minitage.shell/$THIS" "$w/$THIS"
    ln -sf "$w/sources/minitage.shell/$THIS" "$w/bin/$THIS"
    ln -sf "$w/sources/minitage.shell/minitage-git.sh" "$w/bin/minitage-git.sh"
}


reorder_urls() {
    local url="$1" good="$2" ret=""
    shift;shift;
    clone_urls="$@"
    for i in $clone_urls;do
        if [[ "$i" != "$url" ]];then
            ret="$ret $i"
        fi
    done
    # make this url the last tested
    if [[ "${good}" == "0" ]];then
        ret="$url $ret"
    # make this url the first tested
    else
        ret="$ret $url"
    fi
    echo $ret
}

checkout_or_update() {
    green "Synchronnising minitage codebase"
    for d in sources eggs/cache;do
        if [[ ! -d "$d" ]];then
            mkdir -pv "$d"
        fi
    done
    qpushd sources
    local cl_u=$GIT_URLS
    for i in $(echo $minitage_eggs minitage.shell);do
        local updated=""
        if [[ ! -d $i ]];then
            for urlt in ${cl_u};do
                local url="${urlt}/$i.git"
                log "Cloning $url"
                git clone  "$url"
                local ret="$?"
                if [[ "$ret" == "0" ]];then
                    updated="1"
                    cl_u=$(reorder_urls $urlt 0 $cl_u)
                    break
                else
                    cl_u=$(reorder_urls $urlt 1 $cl_u)
                    rm -rf "$i"
                fi
            done
            if [[ ! -d "$i" ]];then
                die "cloning $i failed"
            fi
        elif [[ -n $ONLINE ]];then
            qpushd "$i"
            for urlt in "" ${cl_u};do
                local url="" args=""
                if [[ -n $urlt ]];then
                    url="${urlt}/$i.git"
                fi
                if [[ -n $url ]];then
                    args="$url master"
                    txt="Pulling from $url"
                else
                    args="origin master"
                    txt="Pulling $i"
                fi
                log "$txt"
                git pull $args
                local ret="$?"
                if [[ "$ret" == "0" ]];then
                    if [[ -n $url ]];then
                        warn "Setting remote to $url"
                        git remote set-url origin "$url"
                    fi
                    cl_u=$(reorder_urls $urlt 0 $cl_u)
                    updated="1"
                    break
                else
                    cl_u=$(reorder_urls $urlt 1 $cl_u)
                fi
            done
            qpopd
        fi
        if [[ -z "$updated" ]];then
            if [[ -n "$ONLINE" ]];then
                if [[ ! -d "$w/sources/$i" ]];then
                    die "Clone/Pulling $i failed"
                fi
            fi
        fi
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
    green "Bootstrapping minitage"
    local do_step="do_step" cargs=""
    for i in ${COMMAND_ARGS};do
        if [[ $i == "sync" ]];then
            do_step=""
        else
            cargs="$cargs $i"
        fi
    done
    $do_step boot_checkout_or_update
    ONLINE="TRUE" SYNC="TRUE" "$w/$THIS" deploy ${cargs}
}

offlineupgrade() {
    green "Running $THIS in offline mode"
    local do_step="do_step" cargs=""
    for i in ${COMMAND_ARGS};do
        if [[ $i == "sync" ]];then
            do_step=""
        else
            cargs="$cargs $i"
        fi
    done
    install_tool
    ONLINE="n" SYNC="" "$w/$THIS" deploy
    ONLINE="n" SYNC="" "$w/$THIS" deploy_minitage
    ONLINE="n" SYNC="" "$w/$THIS" deploy ${cargs}
}

usage_deploy() {
    red "Installing your a project $(syellow "-> NEED TO HAVE INTERNET & GIT")"
    green "  cd minitage/minilays && git clone minilay"
    green "  $w/$THIS deploy <project minibuild> [ <otherproject> ]"
}

usage_offlinedeploy() {
    red "Installing your a project without internet (need either extracted snapshots or archive dependencies in $w/downloads)"
    green "  $w/$THIS offlinedeploy <project minibuild>"
}

usage_offlineupgrade() {
    red "Reinstalling minitage packages & projects  after an upgrade for tarballs"
    green "  $w/$THIS offlineupgrade <project minibuild>"
}

usage_snapshot() {
    red "Produce minitage snapshots $(syellow "(can filter projects to archive)")"
    green "  $w/$THIS snapshot [ <project> [ ... <project> ]]]"
    log "  $(sgreen -) $(sblue "${ARCHIVES_PATH}/<minitageoffline-CHRONO-base.tar.gz>")      $(sgreen ": Minitage base code")"
    log "  $(sgreen -) $(sblue "${ARCHIVES_PATH}/<minitageoffline-CHRONO-downloads.tar.gz>") $(sgreen ": Download & egg cache")"
    log "  $(sgreen -) $(sblue "${ARCHIVES_PATH}/<minitageoffline-CHRONO-projects.tar.gz>")  $(sgreen ": Download & egg cache")"
    log
    red "ReDeploy a snapshot with:"
    warn "WARNING: it touches ~/.buildout/default.cfg to set the local download cache"
    green "     tar xzvf <minitageoffline-CHRONO-base.tar.gz>"
    green "     tar xzvf <minitageoffline-CHRONO-downloads.tar.gz>"
    green "     tar xzvf <minitageoffline-CHRONO-projects.tar.gz>"
    green "     $w/$THIS offlinedeploy <project> [... <project3>]$(sblue "# install an offlinizable-minitage in the current directory")"
}

usage_bootstrap() {
    red "Bootstrapping (AKA installing) minitage or upgrading from minitage non-tool installations"
    warn "WARNING: it touches ~/.buildout/default.cfg to set the local download cache"
    green "  cd minitage_root"
    green "  wget -O $THIS https://raw.github.com/minitage/minitage.shell/master/$THIS"
    green "  chmod +x $THIS"
    green "  $THIS bootstrap $(sblue "# take a coffee...")  $(syellow "-> NEED TO HAVE INTERNET & GIT")"
}

usage_selfupgrade(){
    red "Upgrade minitage"
    green "     $w/$THIS selfupgrade"
}

usage_cgwb(){
    red "Launch cgwb"
    green "     $w/$THIS cgwb"
    green " Then visite http://localhost:8085"
}

usage() {
    syellow "               --------------------"
    syellow "               | MINITAGE  HELPER |"
    syellow "               --------------------"
    blue "$(sgreen $THIS ${script_usage}) to list commands"
    log
    usage_bootstrap
    log
    usage_deploy
    log
    usage_offlinedeploy
    log
    usage_offlineupgrade
    log
    usage_snapshot
    log
    usage_selfupgrade
    log
    usage_cgwb
    log
    red "$script_usage_intern"
    warn "      Aadvanced/internal commands, see the code if you want to use them"

}
script_usage="usage"
script_usage_self="bootstrap|selfupgrade|offlineupgrade"
script_usage_deploy="deploy|offlinedeploy|snapshot|cgwb"
script_usage_intern="refresh|checkout_or_update|eggpush|mount|sync|push"
short_usage() {
    echo
    sgreen "$(sgreen Run )$(sblue " $0 ${script_usage}           ")$(sgreen " for long help")"
    sgreen "$(sgreen Run )$(sblue " $0 ${script_usage} <COMPMAND>")$(sgreen " for command help")"
    echo
    sgreen "$0 $(syellow "Maintain: ")$(sred  ${script_usage_self})"
    sgreen "$0 $(syellow "Use:      ")$(sred  ${script_usage_deploy})"
    sgreen "$0 $(syellow "Internal: ")$(sred  ${script_usage_intern})"
}
help_commands="bootstrap snapshot deploy bootstrap offlinedeploy selfupgrade cgwb offlineupgrade"
case $command in
    deploy_minitage|eggpush|offlineupgrade|offlinedeploy|bootstrap|push|deploy|do_selfupgrade|snapshot|sync|refresh|checkout_or_update|selfupgrade|cgwb) $command ${COMMAND_ARGS} ;;
    mount) do_${command} ${COMMAND_ARGS};;
    help|--help|-h|usage)
        for i in ${COMMAND_ARGS};do
            for c in $help_commands;do
                if [[ "$i" == "$c" ]];then
                    short_usage
                    echo
                    usage_$i
                    exit
                fi
            done
        done
        log
        usage
        ;;
    *)
        short_usage
        ;;
esac
# vim:set et sts=4 ts=4 tw=80:

