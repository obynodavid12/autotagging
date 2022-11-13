#!/bin/bash

RELEASEDATE=$(date '+%Y%m%d')
RELEASENOTES=""
GIT_COMMIT=""
VERSION=""

conditional_echo() {
    if [[ "$RUNQUIET" -eq 0 ]]; then
        echo "$1"
    fi
}

while [[ "$#" -gt 0 ]]
do
    case $1 in
      -d|--date)
        RELEASEDATE=$2
        ;;
      -m|--message)
        RELEASENOTES=$2
        ;;
      -p|--previous)
        GIT_COMMIT=$2
        ;;
      -t|--type)
        VERSIONTYPE=$2
        ;;
      -v|--verbose)
        # See if a second argument is passed, due to argument reassignment to -v.
        if [[ "$1" == "-v" ]] && [[ -n "$2" ]]; then
            echo "ERROR: Unsupported value \"$2\" passed to -v argument. If trying to set semantic version tag, use the -t or --type argument".
            exit
        fi
#get highest tag number
VERSION=`git describe --abbrev=0 --tags 2>/dev/null`

if [ -z $VERSION ];then
    NEW_TAG="3.8.12.7.0"
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
VNUM1=${VERSION_BITS[0]}
VNUM2=${VERSION_BITS[1]}
VNUM3=${VERSION_BITS[2]}
VNUM4=${VERSION_BITS[3]}
VNUM5=${VERSION_BITS[4]}
VNUM5=$((VNUM5+1))

#create new tag
NEW_TAG="v${VNUM1}.${VNUM2}.${VNUM3}.${VNUM4}.${VNUM5}_hotfixes"

#get current hash and see if it already has a tag
GIT_COMMIT=$(echo $(git rev-parse HEAD))
CURRENT_COMMIT_TAG=$(echo $(git describe --contains $GIT_COMMIT 2>/dev/null))

#only tag if no tag already (would be better if the git describe command above could have a silent option)
if [ -z "$CURRENT_COMMIT_TAG" ]; then
    echo "Updating $VERSION to $NEW_TAG"
    git tag -a $NEW_TAG  -m "$RELEASEDATE: Release $VNUM1.$VNUM2.$VNUM3.$VNUM4.$VNUM5" -m"$RELEASENOTES" $GIT_COMMIT
    git push --tags
    echo "Tag created and pushed: $NEW_TAG"
else
    echo "This commit is already tagged as: $CURRENT_COMMIT_TAG"
fi
esac
shift
done