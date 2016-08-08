#!/bin/bash

##############################################################
#
# Creado por: Manuel Gil
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
#			G E N E R A C I Ó N   D E   K E Y S
##############################################################

if [ ! -f ~/.ssh/id_rsa ]; then
    printf "${BLUE}-- Generando keys --${NC}\n"
	ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""
fi

printf "${BLUE}-- Autenticando acceso con el Ranchito's Server (De ser necesario, deberá ingresar la clave del servidor) --${NC}\n"
ssh-copy-id root@190.121.226.235 -p 2224
printf "${GREEN}-- Listo! Ya tienes acceso sin autenticación al Ranchito's Server --${NC}\n"

##############################################################
#		C O N F I G U R A C I Ó N   D E L   S E R V I D O R
##############################################################

ssh -t -t root@190.121.226.235 -p 2224 "
	cd /home/git
	mkdir '$repository.git'
	cd '$repository.git'
	git --bare init
	git config core.sharedRepository true
	printf '${GREEN}-- EXITO: Repositorio creado!... --${NC}\n'
"

##############################################################
#		C O N F I G U R A C I Ó N   D E L   C L I E N T E
##############################################################

printf "${BLUE}-- Creando repositorio local si no estaba creado... --${NC}\n"
git init
printf "${BLUE}-- Agregando archivos... --${NC}\n"
git add *
printf "${BLUE}-- Creando el commit... --${NC}\n"
git commit -m "INITIAL COMMIT TO RANCHITO'S SERVER"
git remote add ranchito "git+ssh://root@190.121.226.235:2224/home/git/$repository.git"
printf "${BLUE}-- Cargando el estado del proyecto al: Ranchito's Server --${NC}\n"
git push ranchito master
printf "${GREEN}-- Listo, ahora puedes seguir trabajando en tu proyecto... --${NC}\n"

exit
