#!/bin/bash
# 
# Script for setting up the right permissions for a web directory (files and dirs)
#
#                                                                            @myei


# validations
[[ -z $1 ]] && echo "usage: webdir-permissions.sh [PATH]" && exit 1
[[ ! -d $1 ]] && echo "error: path doesn't exists" && exit 2

# permissions
echo "changing permissions on $1 to dirs..."
find $1 -type d -print0 | xargs -0 chmod 0755
echo "changing permissions on $1 to files..."
find $1 -type f -print0 | xargs -0 chmod 0644
