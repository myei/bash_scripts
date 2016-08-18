#!/bin/bash

##############################################################
#
# 					Creado por: Manuel Gil
#
# Este script permite:
#
# - Generar keys rsa y autoconexion con el servidor
# 	* 190.121.226.235
#
# - Crear repositorio Git en el servidor permitiendo el uso
# 	compartido
#
# - Enlazar el proyecto con el repositorio creado y sincronizar 
# 	el estado del proyecto automáticamente al servidor
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

##############################################################
#		N O M B R E   D E L   R E P O S I T O R I O
##############################################################

printf "${CYAN}-- Introduce el nombre del respositorio a crear (sin .git): --${NC}\n"
read repository 

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
