#!/usr/bin/env bash
WHERE="$1"
if [[ -z $WHERE ]];then
        WHERE="$PWD"
fi
PACKAGE="$(basename $WHERE)"
BASE_URL="https://kiorky@github.com/minitage-dependencies"
BASE_URL="git@github.com:minitage-dependencies"
EGGS_URL="https://kiorky@github.com/minitage-eggs"
EGGS_URL="git@github.com:minitage-eggs"
MINILAYS_URL="https://kiorky@github.com/minitage/minilays.2.0."
URL="$BASE_URL/$PACKAGE"
if [[ $(echo $WHERE|sed -re "s/.*minilays.*/go/g") == "go" ]];then
    URL="$MINILAYS_URL$PACKAGE"
fi
if [[ $(echo $WHERE|sed -re "s/.*eggs.*/go/g") == "go" ]];then
        URL="$EGGS_URL/$PACKAGE"
fi
echo "Using $URL";read
rm -rf .git
git init
git config github.user kiorky
#git config github.token ef97c740b8e43f0c8fcc339584e9d9c9
git config user.email  kiorky@cryptelium.net
git config user.name  kiorky
git config branch.master.merge refs/heads/master
git config branch.master.remote origin
git remote add origin $URL.git
git pull -f
