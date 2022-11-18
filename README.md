# autotagging

git tag v1.2.3 -m "Release version 1.2.3", in which case “v1.2.3” is a tag name and the semantic version is “1.2.3”.
https://gist.github.com/igorcosta/3754e5acc1d7f89469d39b1c293bfa61

Incrementing npm version and git tagging

https://github.com/marketplace/actions/increment-semantic-version


https://stackoverflow.com/questions/69343233/github-action-increment-version-on-push-to-main

https://buddy.works/guides/semantic-versioning


https://www.sipios.com/blog-tech/tips-for-creating-stunning-software-releases-automatically


https://stackoverflow.com/questions/49655467/shell-script-bump-version-automatically-git


https://stackoverflow.com/questions/3760086/automatic-tagging-of-releases


https://stackoverflow.com/questions/3760086/automatic-tagging-of-releases


https://gist.github.com/bclinkinbeard/1331790


https://gist.github.com/CSTDev/08c127680e3b5fae38c051da3e489351


https://gist.github.com/dtiemann83/cfa16ade69a3ea451ad760d4118a9351


https://stackoverflow.com/questions/57142242/get-the-last-tags-from-git-tag-list-v



https://github.com/franiglesias/versiontag



#Check this out
https://whatthepatch.blogspot.com/2017/06/git-auto-increment-tag.html?m=1



https://coderwall.com/p/hjy-6q/manage-version-changes-and-git-tags-with-a-bash-script


https://www.appsloveworld.com/bash/100/22/shell-script-bump-version-automatically-git


VERSION=`git describe --tags --abbrev=0 | awk -F. '{OFS="."; $NF+=1; print $0}'`
git tag -a $VERSION -m "new release"
git push origin $VERSION






https://github.com/marketplace/actions/create-an-incremental-tag


https://github.com/marketplace/actions/bump-n-tag-version


https://github.com/mathieudutour/github-tag-action



# USING VERSION FILE
# https://github.com/marketplace/actions/bump-n-tag-version

ERROR MESSAGE WHEN RUNNING THE ABOVE BUMP-N-TAG-VERSION
Running a container (via uses: docker://…) however switches the user context and all git commands will fail with an error:

fatal: detected dubious ownership in repository at '/github/workspace'
To add an exception for this directory, call:

	git config --global --add safe.directory /github/workspace

# https://github.com/actions/checkout/issues/766   --Resolving dubious owner- we could change
update to the latest version of checkout. v3

# Simply set the GITHUB_WORKSPACE as a safe directory.
git config --global --add safe.directory "$GITHUB_WORKSPACE"    --added this to the entrypoint.sh file


# If your github workspace starts off with //, you may need to set it via
git config --global --add safe.directory "%(prefix)/$GITHUB_WORKSPACE"

# https://github.com/actions/runner/issues/2033


Inspecting the docker run command the HOME variable is set and the home inside the container seems to be /github/home which is mapped to /home/runner/work/_temp/_github_home.
Creating the .gitconfig in this location before running the container resolves this problem:

- name: Fix git safe.directory in container
  run: mkdir -p /home/runner/work/_temp/_github_home && printf "[safe]\n\tdirectory = /github/workspace" > /home/runner/work


To Reproduce
Steps to reproduce the behavior:

Create this minimal workflow and let it run

on:
  push:

jobs:
  fails:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: docker://docker.io/library/alpine:3.14
        with:
          entrypoint: /bin/ash
          args: -c "apk add git && git status"


#ANOTHER RESOLUTION
Got the same issue, though in different scenario. My workaround was to just change owner of the directory after checkout:

jobs:
  ubuntu-gcc:
    runs-on: ubuntu-20.04
    name: "Linux Ubuntu"
    container:
      image: ubuntu:20.04
    env:
      DEBIAN_FRONTEND: noninteractive
      TZ: Etc/UTC
    steps:
      - name: Install GIT
        run: |
          # install GIT, as without it checkout would use REST API
          apt update
          apt install -y \
            git

      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Set ownership
        run: |
          # this is to fix GIT not liking owner of the checkout dir
          chown -R $(id -u):$(id -g) $PWD
