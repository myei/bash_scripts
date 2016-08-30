#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\e[95m'
NC='\033[0m'
BOLD='\e[1m'
NF='\e[0m'
BLINK='\e[5m'

AMAZON='ubuntu@54.204.107.45'
isNumber="^-?[0-9]+([.][0-9]+)?$"
repoSelected=""

validateCertificate() {
	printf "\n\n${CYAN} Validando certificados...${NC}\n\n"
	if [[ $(grep -lir "LB-PMO.pem" /etc/ssh/ssh_config) = "" ]]; then
		printf "${RED} -- ERROR: No estas autenticado con el servidor, debes ejecutar la primera opción y autenticarte correctamente --${NC}\n"
		exit 1
	fi
}

clear
printf "${CYAN}\n ${BOLD}Buscando repositorios...\n\n${NC}"

array=($(ssh $AMAZON ls /home/ubuntu/git))

cont=0
for item in ${array[*]}
do
	printf "     [${CYAN}${BOLD}$cont${NC}] %s\n" $item
	let cont+=1
done


printf "\n ${CYAN}${BOLD}Seleccione el repositorio a eliminar:${NF}${NC}\n"
read repoSelec

if [[ $repoSelec > ${#array[*]} || $repoSelec < 0 || !($repoSelec =~ $isNumber) || $repoSelec = "" ]]; then
	printf "${RED}${BOLD}!--- ERROR: Debe seleccionar un repositorio... ---!${NC}\n\n"
	exit 1
fi

ssh -t -t $AMAZON "
	if [ -d /home/ubuntu/git/${array[$repoSelec]} ]; then
		sudo rm -r /home/ubuntu/git/${array[$repoSelec]}
	fi	
"
printf "\n${GREEN} ${BOLD}Repositorio eliminado... ${NC}\n\n"
exit