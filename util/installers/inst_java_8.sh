#!/bin/bash

apt install software-properties-common -y
add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main"
apt update
apt install oracle-java8-installer -y
javac -version
