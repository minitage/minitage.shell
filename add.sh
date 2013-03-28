#!/usr/bin/env bash
cd $(dirname $0)
for i in dependencies/*/buildout.cfg eggs/*/buildout.cfg;do
    have_bm=$(grep minitagificator $i|wc -l)
    grep extens $i
    if [[ "$have_bm" == "0" ]];then
        pushd $(dirname  $i)
        sed -re "/\[buildout\]/ {
a extensions=buildout.minitagificator
}" -i $(basename $i)
        git commit -am "add extention"
        git push
        popd 
    fi
done
# vim:set et sts=4 ts=4 tw=80:
