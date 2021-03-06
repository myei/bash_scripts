#!/bin/sh

echo 'getting resources...'
wget https://github.com/libgit2/libgit2/archive/v0.26.0.tar.gz
tar xzf v0.26.0.tar.gz
cd libgit2-0.26.0
cmake .
make
make install
apt install libffi-dev
cd ..
echo 'cleaning...'
rm -r libgit2-0.26.0 v0.26.0.tar.gz
echo 'installing pygit2...'
pip install pygit2
pip3 install pygit2
