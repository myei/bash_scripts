#!/bin/bash

# pre-reqs (might change in the future)
apt install -y build-essential libc6-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev
# get source code
cd $HOME
wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tgz
tar -zxvf Python-3.6.1.tgz
cd Python-3.6.1
# build & install
./configure
make -j4          # using 4 threads for some speed
make install
# cleanup
cd ..
rm -fr ./Python-3.6.1*
# upgrade (just in case)
pip3 install -U pip
pip3 install -U setuptools
# verify
python3 --version
pip3 --version
