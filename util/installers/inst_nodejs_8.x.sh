#!/bin/bash

apt install curl python-software-properties -y
curl -sL https://deb.nodesource.com/setup_9.x | bash -
apt install nodejs -y
node -v
npm -v
