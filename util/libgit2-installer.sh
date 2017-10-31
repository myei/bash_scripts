#!/bin/sh
apt-get install build-essential libffi-dev python3-dev pkg-config libssh2-1-dev libhttp-parser-dev libssl-dev libz-dev
wget https://github.com/libgit2/libgit2/archive/v0.22.0.tar.gz
tar xzf v0.22.0.tar.gz
cd libgit2-0.22.0/
cmake .
make
make install
