#!/bin/bash

#############################################################################
#
# 										Creado por: Manuel Gil
#
#  	Este script facilita la limpieza de cache de proyectos hechos en Symfony:
#
# 		- Limpieza de cache 
# 		- Asignación de permisos a archivos y directorios
# 		- Asignación de usuario y grupo a archivos y directorios
# 		- Instalación automática de assets en Symfony 3
#
# 																	 v2.3.1
############################################################################

# CONFIGURATION #
PROJECT_USER='apache'
PROJECT_GROUP='apache'
PROJECT_ENV='prod'
PHP_PATH=php

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\e[97m'
YELLOW='\e[93m'
NC='\033[0m'
I='\e[3m'

BOLD='\e[1m'
#################

if [[ $# -eq 0 ]]; then
	printf "${RED}${BOLD}Error: invalid argument \n\n"
	printf "Use script: clear-cache [project route] or clear-cache --here ${NC} \n\n"
	exit
else 

	if [[ $1 != "--here" ]]; then
		if [ -d $1 ]; then
			printf "${WHITE}${BOLD}Changing directory to $1 \n"
			cd $1
		else
			printf "${RED}${BOLD}Directory $1 does not exists! ${NC} \n"
			exit
		fi
	fi

	if [[ -f bin/console ]]; then
		if [[ -f .env ]]; then
			printf "${GREEN}${BOLD}Symfony project detected [>= v4], clearing cache...${NC} \n"
			sudo $PHP_PATH bin/console cache:clear --env=$PROJECT_ENV
			sudo chown -R $PROJECT_USER:$PROJECT_GROUP .
			sudo setfacl -d -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,log} public && sudo setfacl -dR -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,log} public
		else
			printf "${GREEN}${BOLD}Symfony project detected [<= v3], clearing cache and setting permissions...${NC} \n"
			sudo rm -rf var/cache/* && $PHP_PATH bin/console cache:clear --env=$PROJECT_ENV --no-warmup
			sudo $PHP_PATH bin/console assets:install --symlink --relative web 
			sudo chown -R $PROJECT_USER:$PROJECT_GROUP .
			sudo setfacl -d -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,logs,sessions} web && setfacl -dR -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,logs,sessions} web
		fi
	fi

	exit
fi
