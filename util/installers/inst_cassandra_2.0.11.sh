#!/bin/bash

echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl -L http://debian.datastax.com/debian/repo_key | apt-key add -
apt update
apt install dsc20=2.0.11-1 cassandra=2.0.11 -y
