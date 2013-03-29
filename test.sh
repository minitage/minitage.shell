#!/usr/bin/env bash
cd $(dirname $0)
if [[ ! -d tmp ]];then
    mkdir tmp
fi
rsync -a ../../sources/  tmp/sources/ --exclude=tmp
cp minitagetool.sh tmp
cd tmp
if [[ "$1" == "full" ]];then
        rm -rf bin cpan dependencies eggs etc include lib logs minilays  tools
        rm -f .compiled*
fi
./minitagetool.sh bootstrap
# vim:set et sts=4 ts=4 tw=80:
