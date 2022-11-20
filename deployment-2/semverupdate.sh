#!/bin/bash

VERSION=""

#get parameters
while getopts v: flag
do
  case "${flag}" in
    v) VERSION=${OPTARG};;
  esac
done

#get highest tag number, and add 1.0.0 if doesn't exist
CURRENT_VERSION=`git describe --abbrev=0 --tags always 2>/dev/null` 

if [[ $CURRENT_VERSION == '' ]]
then
  CURRENT_VERSION='x1b-1.0.0.0.0'
fi
echo "Current Version: $CURRENT_VERSION"


#replace . with space so can split into an array
CURRENT_VERSION_PARTS=(${CURRENT_VERSION//./ })

#get number parts
VNUM1=${CURRENT_VERSION_PARTS[0]}
VNUM2=${CURRENT_VERSION_PARTS[1]}
VNUM3=${CURRENT_VERSION_PARTS[2]}
VNUM4=${CURRENT_VERSION_PARTS[3]}
VNUM5=${CURRENT_VERSION_PARTS[4]}
VNUM5=$((VNUM5+1))

#create new tag
git config --global user.name "$(git --no-pager log --format=format:'%an' -n 1)"
git config --global user.email "$(git --no-pager log --format=format:'%ae' -n 1)"
git config --global --add safe.directory "$GITHUB_WORKSPACE"
NEW_TAG="$VNUM1.$VNUM2.$VNUM3.${VNUM4}.${VNUM5}"
echo "($VERSION) updating $CURRENT_VERSION to $NEW_TAG"

#get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

#only tag if no tag already
#to publish, need to be logged in to npm, and with clean working directory: `npm login; git stash`
if [ -z "$NEEDS_TAG" ]; then
  git tag -a $NEW_TAG
  echo "Tagged with $NEW_TAG"
  git push --tags
  git push
else
  echo "Already a tag on this commit"
fi
exit 0


