#!/usr/bin/env bash

commit_hashes=($(git ls-remote --tags --refs -q  | awk '{ print $1 }'))
tags=($(git ls-remote --tags --refs -q | awk '{ print $2 }' | sed 's/refs\/tags\///'))

COUNTER=0
echo "Start processing ${#tags[@]} tags"
echo "================================="
for tag in "${tags[@]}"
do
  hash=${commit_hashes[COUNTER]}
  if [[ "${tag}" != y1b-* ]]
  then
    echo "Add new tag 'y1b-${tag}' to local repo on commit ${hash}"
    eval "git tag ${tag} ${hash}"

    echo "Delete old tag '${tag}' from local"
    eval "git tag --delete ${tag}"

    echo "Delete old tag '${tag}' from remote"
    eval "git push origin :refs/tags/${tag}"

    echo "---------------------------------"
    let COUNTER=COUNTER+1
  fi
done

echo "Push all local tags to remote"
eval "git push origin --tags""
echo "Finished"
echo "================================="
