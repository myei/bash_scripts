#!/bin/bash

##############################################################
#
# 					Creado por: Manuel Gil
#
# Este script permite:
#
# - Crear repositorio Git (si no existe) en el servidor 
# 	permitiendo el uso compartido
#
# - Enlazar el proyecto con el repositorio y sincronizar 
# 	el estado del proyecto automáticamente al servidor
#
#	NOTA: Este script debe ser ejecutado desde la ruta del 
#		  proyecto que se quiere enlazar con el AWS
#
##############################################################

##############################################################
#					G L O B A L E S
##############################################################

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

AMAZON='ubuntu@54.204.107.45'
repoSelected=""

##############################################################
#						M E N Ú
##############################################################

printf "Que acción desea realizar? \n\n"
printf "[1] Crear repositorio y enlazar \n"
printf "[2] Enlazar a un repositorio existente \n"

read option
if [ "$option" = "2" ]; then
	printf "${BLUE}\n---------------------------------------------\n\n${CYAN}"

	array=($(ssh $AMAZON ls /home/ubuntu/git))
	cont=1
	for item in ${array[*]}
	do
		printf "[$cont] %s\n" $item
		let cont+=1
	done

	printf "Introduzca el repositorio a enlazar\n"
	read repoSelec

	if [ "$repoSelec" = "" ]; then 
		printf "${RED}!--- ERROR: Debe seleccionar un repositorio... ---!${NC}\n"
    	exit 1
	fi

   	repository=$repoSelec
else
	
fi

printf "${BLUE}\n---------------------------------------------\n"
printf "${NC}\n"

##############################################################
#		N O M B R E   D E L   R E P O S I T O R I O
##############################################################

if [ "$repoSelected" = ""]; then
	printf "${CYAN}-- Introduce el nombre del respositorio a crear (sin .git): --${NC}\n"
	read repository
fi 

if [ "$repository" = "" ]; then
	printf "${RED}!--- ERROR: Debe ingresar el nombre del repositorio... ---!${NC}\n"
    exit 1
fi

##############################################################
#		C O N F I G U R A C I Ó N   D E L   S E R V I D O R
##############################################################

ssh -t -t $AMAZON "
	if [ ! -d /home/ubuntu/git/$repository.git ]; then
		cd /home/ubuntu/git
		mkdir '$repository.git'

		cd '$repository.git'
		git --bare init
		git config core.sharedRepository true
		printf '${GREEN}-- EXITO: Repositorio creado!... --${NC}\n'
	fi	
"

##############################################################
#		C O N F I G U R A C I Ó N   D E L   C L I E N T E
##############################################################

printf "${BLUE}-- Creando repositorio local si no estaba creado... --${NC}\n"
git init
printf "${BLUE}-- Agregando archivos... --${NC}\n"
git add *
printf "${BLUE}-- Creando el commit... --${NC}\n"
git commit -m "INITIAL COMMIT TO AWS'S SERVER"
git remote add aws "git+ssh://$AMAZON/home/ubuntu/git/$repository.git"
printf "${BLUE}-- Cargando el estado del proyecto al: AWS's Server --${NC}\n"
git push aws master
printf "${GREEN}-- Listo, ahora puedes seguir trabajando en tu proyecto... --${NC}\n"
printf "${CYAN}-- NOTA: tus pushs deben estar dirigidos a 'aws' (git push aws <branch>)... --${NC}\n"

exit
