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
# - Clonar un proyecto existente desde servidor de Git
#
#	NOTA: Este script debe ser ejecutado desde la ruta del 
#		  proyecto que se quiere enlazar con el AWS, o desde
#		  donde se le quiere clonar
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
isNumber="^-?[0-9]+([.][0-9]+)?$"
repoSelected=""

##############################################################
#						M E N Ú
##############################################################

printf "Que acción desea realizar? \n\n"
printf "[1] Crear repositorio y enlazar \n"
printf "[2] Enlazar a un repositorio existente \n"
printf "[3] Clonar repositorio \n"

read option
if [[ $option = "2" || $option = "3"  ]]; then
	printf "${NC}\nBuscando repositorios...\n\n${NC}"

	array=($(ssh $AMAZON ls /home/ubuntu/git))

	printf "${GREEN}\n---------------------------------------------\n\n${NC}"
	cont=0
	for item in ${array[*]}
	do
		printf "[$cont] %s\n" $item
		let cont+=1
	done

	printf "${GREEN}\n---------------------------------------------\n\n${NC}"

	printf "\nSeleccione un repositorio\n"
	read repoSelec

    if [[ $repoSelec > ${#array[*]} || $repoSelec < 0 || !($repoSelec =~ $isNumber) || $repoSelec = "" ]]; then
		printf "${RED}!--- ERROR: Debe seleccionar un repositorio... ---!${NC}\n"
		exit 1
	fi

   	repository=${array[$repoSelec]}

elif [[ $option != "1" ]]; then
	printf "\n${RED}!--- ERROR: Debe seleccionar una opción... ---!${NC}\n"
	exit 1
fi

##############################################################
#		N O M B R E   D E L   R E P O S I T O R I O
##############################################################

if [[ $repository = "" ]]; then
	printf "\n${CYAN}-- Introduce el nombre del respositorio a crear (sin .git): --${NC}\n"
	read newRepo
	if [ $newRepo = "" ]; then
		printf "\n${RED}!--- ERROR: Debe ingresar el nombre del repositorio... ---!${NC}\n"
	    exit 1
	fi
	repository=$newRepo".git"
fi 

##############################################################
#		C O N F I G U R A C I Ó N   D E L   S E R V I D O R
##############################################################
if [[ $option = "1" ]]; then
	printf "\n\n${NC}Creando repositorio remoto...${NC}\n\n"

	ssh -t -t $AMAZON "
		if [ ! -d /home/ubuntu/git/$repository ]; then
			cd /home/ubuntu/git
			mkdir '$repository'

			cd '$repository'
			git --bare init
			git config core.sharedRepository true
			printf '\n${GREEN}-- EXITO: Repositorio creado!... --${NC}\n\n'
		fi	
	"
fi

##############################################################
#		C O N F I G U R A C I Ó N   D E L   C L I E N T E
##############################################################

if [[ $option != "3" ]]; then
	printf "\n${BLUE}-- Creando repositorio local si no estaba creado... --${NC}\n\n"
	git init
	printf "\n${BLUE}-- Agregando archivos... --${NC}\n\n"
	git add *
	printf "\n${BLUE}-- Creando el commit... --${NC}\n\n"
	git commit -m "INITIAL COMMIT TO AWS'S SERVER"
	git remote add aws "git+ssh://$AMAZON/home/ubuntu/git/$repository"
	printf "\n${BLUE}-- Cargando el estado del proyecto al: AWS's Server --${NC}\n\n"
	git push aws master
else
	printf "\n${BLUE}-- Clonando repositorio --${NC}\n\n"
	git clone git+ssh://$AMAZON/home/ubuntu/git/$repository
	cd ${repository:0:-4}
	git remote rename origin aws
fi
	printf "\n${GREEN}-- Listo, ahora puedes seguir trabajando en tu proyecto... --${NC}\n\n"
	printf "\n${CYAN}-- NOTA: tus pushs deben estar dirigidos a 'aws' (git push aws <branch>)... --${NC}\n\n"

exit
