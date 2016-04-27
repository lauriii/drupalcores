#!/bin/bash

TARGET=$1
BRANCH=$2
AFTER=$3
BEFORE=$4

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 TARGET BRANCH AFTER [BEFORE]"
  exit 1;
fi

git pull

echo "Updating Sub Repos"

if [ ! -d "./app/drupalcore" ]; then
  git clone --branch $BRANCH http://git.drupal.org/project/drupal.git ./app/drupalcore
else
  cd ./app/drupalcore
  git checkout $BRANCH
  git pull
  cd ../bin
fi

./cores.rb > ../../dist/next.html
./json.rb > ../../dist/next.json

cd ../../dist
mv next.html $TARGET.html
mv next.json $TARGET.json
