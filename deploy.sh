#!/usr/bin/env bash
# https://github.com/iKevinY/iKevinY.github.io/blob/src/deploy.sh

GH_PAGES_BRANCH=master
TARGET_REPO=blaskovicz/blaskovicz.github.io
REMOTE_DIR=../remote-site

if [ "$TRAVIS" == "true" ]; then
  echo "Deploying site to GitHub Pages via Travis CI."
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  GITHUB_REPO=https://${GH_TOKEN}@github.com/$TARGET_REPO
else
  GITHUB_REPO=git@github.com:blaskovicz/blaskovicz.github.io.git
fi

# Pull hash and commit message of most recent commit
commitHash=$(git rev-parse HEAD)
commitMessage=$(git log -1 --pretty=%B)

# Clone the GitHub Pages branch and rsync it with the newly generated files
ROOT_DIR=`pwd`
git clone --branch=$GH_PAGES_BRANCH --depth 1 $GITHUB_REPO $REMOTE_DIR > /dev/null
pushd $REMOTE_DIR > /dev/null
rsync -r \
  --exclude node_modules \
  --exclude='.gems*' \
  --exclude=.git \
  --exclude=.sass-cache \
  --delete \
  $ROOT_DIR/ ./

# Add, commit, and push files to the GitHub Pages branch
git add -A
git status -s

if [ "$TRAVIS" == "true" ]; then
  longMessage="Generated by commit $commitHash; pushed by Travis build $TRAVIS_BUILD_NUMBER."
  git commit -m "$commitMessage" -m "$longMessage"
  git push -fq origin $GH_PAGES_BRANCH > /dev/null
else
  read -p "Manually push changes to GitHub Pages branch? [y/N] " response
  if [[ "$response" == 'y' ]] || [[ "$response" == 'Y' ]]; then
    git commit -m "$commitMessage" -m "Generated by commit $commitHash."
    git push -f origin $GH_PAGES_BRANCH
  fi

  popd > /dev/null
  rm -rf -- $REMOTE_DIR && echo "Removed $REMOTE_DIR"
fi