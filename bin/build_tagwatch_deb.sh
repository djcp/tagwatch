#!/bin/bash

cp ./tagwatch.sh pkg-build/tagwatch/usr/bin/tagwatch
cp ./tagwatch_all_git_repos.sh pkg-build/tagwatch/usr/bin/tagwatch_all_git_repos

cd pkg-build
dpkg --build tagwatch
cd ..

echo "tagwatch.deb has been built in pkg-build/tagwatch.deb'
