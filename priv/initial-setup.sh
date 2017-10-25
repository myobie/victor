#!/bin/bash -x

set -e
set -x

path=$1
url=$2

if [ -z $path ]; then
  echo "You must provide a local path. Ex: /path/to/hugo-website/"
  exit 1
fi

if [ -z $url ]; then
  echo "You must provide a remote git url. Ex: https://u:p@example.com/repo"
  exit 1
fi

version_path="$path/versions/0"
current_path="$path/versions/current"

mkdir -p $version_path
ln -n -f -s $version_path $current_path

cd $path
git clone $url repo
