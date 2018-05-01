#!/bin/bash -x

set -e
set -x

path=$1
rev=$2
baseurl=$3

if [ -z $path ]; then
  echo "You must provide a local path. Ex: /path/to/hugo-website/"
  exit 1
fi

if [ -z $rev ]; then
  echo "You must provide a git revision. Ex: master"
  exit 1
fi

if [ -z $baseurl ]; then
  echo "You must provide a base URL. Ex: http://example.com"
  exit 1
fi

origin_rev="origin/$rev"
repo_path="$path/repo"
current_path="$path/versions/current"
old_rev=$(readlink $current_path)

cd $repo_path
git reset --hard HEAD
git clean -f
git fetch origin
git checkout $origin_rev

version=$(git rev-parse --verify --quiet $origin_rev)
version_path="$path/versions/$version"

mkdir -p $version_path

cp -R $repo_path/* $version_path/

cd $version_path/assets
npm i
npm run build

cd $version_path
hugo --baseURL $baseurl

ln -n -f -s $version_path $current_path

if [ -n "$old_rev" ]; then
  rm -rf $old_rev
fi
