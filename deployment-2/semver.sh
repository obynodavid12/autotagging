#!/bin/bash

#get highest tag number
#VERSION=`git describe --abbrev=0 --tags 2>/dev/null`
VERSION=`git describe --tags --abbrev=0 | awk -F. '{OFS="."; $NF+=1; print $0}'`

if [ -z $VERSION ];then
    NEW_TAG="x1b-3.8.11.1.0"
    echo "No tag present."
    echo "Creating tag: $NEW_TAG"
    git tag $NEW_TAG 
    git push --tags
    echo "Tag created and pushed: $NEW_TAG"
    exit 0;
fi

#replace . with space so can split into an array
VERSION_BITS=(${VERSION//./ })

#get number parts and increase last one by 1
VNUM1=${VERSION_BITS[0]//[^0-9]/}
VNUM2=${VERSION_BITS[1]//[^0-9]/}
VNUM3=${VERSION_BITS[2]//[^0-9]/}
VNUM4=${VERSION_BITS[3]//[^0-9]/}
VNUM5=${VERSION_BITS[4]//[^0-9]/}
VNUM5=$((VNUM5+1))

#create new tag
NEW_TAG="${VNUM1}.${VNUM2}.${VNUM3}.${VNUM4}.${VNUM5}"

#get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
CURRENT_COMMIT_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`


#only tag if no tag already (would be better if the git describe command above could have a silent option)
if [ -z "$CURRENT_COMMIT_TAG" ]; then
    echo "Updating $VERSION to $NEW_TAG"
    git tag $NEW_TAG
    git push --tags
    echo "Tag created and pushed: $NEW_TAG"
else
    echo "This commit is already tagged as: $CURRENT_COMMIT_TAG"
fi


