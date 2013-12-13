#!/bin/bash

cp ./tagwatch pkg-build/tagwatch/usr/bin/tagwatch
cp ./tagwatch_all_git_repos pkg-build/tagwatch/usr/bin/tagwatch_all_git_repos

cd pkg-build
dpkg --build tagwatch
dpkg-sig --sign builder tagwatch.deb
cd ..

echo "tagwatch.deb has been built in pkg-build/tagwatch.deb"

echo 'Building apt repo'

rm -Rf apt-repo

mkdir -p apt-repo/binary
cp pkg-build/tagwatch.deb apt-repo/binary/

cd apt-repo
apt-ftparchive packages binary > Packages
apt-ftparchive release ./ > Release
gpg --output Release.gpg -ba Release

echo "Signed apt repository built in apt-repo/"

# gpg --keyserver subkeys.pgp.net --recv-keys 3BC1C2C3
# gpg --export -a 3BC1C2C3 | apt-key add -
