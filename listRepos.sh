#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

AMAZON='ubuntu@54.204.107.45'

printf "${BLUE}\n---------------------------------------------\n\n${CYAN}"

array=($(ssh $AMAZON ls /home/ubuntu/git))
cont=1
for item in ${array[*]}
do
	printf "[$cont] %s\n" $item
	let cont+=1
done

printf "${BLUE}\n---------------------------------------------\n"
printf "${NC}\n"
