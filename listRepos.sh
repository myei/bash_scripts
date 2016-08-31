#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
ARROW='\u2192'
CHECK='\u2714'
BOLD='\e[1m'

AMAZON='ubuntu@54.204.107.45'

array=($(ssh $AMAZON ls /home/ubuntu/git))
cont=1
printf "\n${BOLD}${ARROW}"
for item in ${array[*]}
do
	printf "	   ${ARROW} %s\n" $item
	let cont+=1
done

printf "${NC}\n"
