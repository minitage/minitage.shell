#!/usr/bin/env bash
WHERE="$1"
if [[ -z $WHERE ]];then
    WHERE=$PWD
fi
cd $WHERE
if [[ $(uname) == "Darwin" ]];then
    SED="sed -E"
else
    SED="sed -re"
fi
WHERE="$PWD"
PACKAGE="$(basename $WHERE)"
HBASE_URL="https://kiorky@github.com/minitage-dependencies"
BASE_URL="git@github.com:minitage-dependencies"
HEGGS_URL="https://kiorky@github.com/minitage-eggs"
EGGS_URL="git@github.com:minitage-eggs"
HMINILAYS_URL="https://kiorky@github.com/minitage/minilays.2.0."
MINILAYS_URL="git@github.com:minitage/minilays.2.0."
URL="$BASE_URL/$PACKAGE"
HURL="$HBASE_URL/$PACKAGE"
if [[ $(echo $WHERE|$SED "s/.*minilays.*/go/g") == "go" ]];then
    URL="$MINILAYS_URL$PACKAGE"
    HURL="$HMINILAYS_URL$PACKAGE"
fi
if [[ $(echo $WHERE|$SED "s/.*eggs.*/go/g") == "go" ]];then
    URL="$EGGS_URL/$PACKAGE"
    HURL="$HEGGS_URL/$PACKAGE"
fi
echo "Using $URL";read
rm -rf .git
git init
git config github.user kiorky
git config user.email  kiorky@cryptelium.net
git config user.name  kiorky
git config branch.master.merge refs/heads/master
git config branch.master.remote origin
git remote add origin $URL.git
git remote add h $HURL.git
echo git remote add h $HURL.git
httppull() {
    git fetch h
    git reset --hard remotes/h/master
}
git pull -f || httppull
