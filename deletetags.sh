#!/bin/bash
#Delete local tags
git tag -d $(git tag -l)
#Fetch remote tags
git fetch
#Delete remote tags
git push origin --delete $(git tag -l)
#Delete local tags
git tag -d $(git tag -l) 
