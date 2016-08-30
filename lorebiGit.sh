#!/bin/bash
##############################################################
#
# 					Creado por: Manuel Gil
#
# Este script permite:
#
# - Autenticar el cliente con el servidor
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
PURPLE='\e[95m'
NC='\033[0m'
BOLD='\e[1m'
NF='\e[0m'
BLINK='\e[5m'

AMAZON='ubuntu@54.204.107.45'
isNumber="^-?[0-9]+([.][0-9]+)?$"
repoSelected=""

##############################################################
#						M E N Ú
##############################################################
clear
#printf "${PURPLE}_______________________________________________________________\n\n${NC}"
printf "\n 	   Bienvenido al ${BOLD}${PURPLE}LorebiGit${NF}\n\n"
printf " ${CYAN}${BOLD}Que acción desea realizar?${NF} \n\n${NC}"
printf "  [${CYAN}${BOLD}1${NC}] Autenticarme con el Servidor [${RED}${BOLD}root${NC}] (${BLUE}${BOLD}Sólo la primera vez${NC})\n"
printf "  [${CYAN}${BOLD}2${NC}] Crear repositorio y enlazar \n"
printf "  [${CYAN}${BOLD}3${NC}] Enlazar a un repositorio existente \n"
printf "  [${CYAN}${BOLD}4${NC}] Clonar repositorio \n"
read option
#printf "\n${PURPLE}_______________________________________________________________\n${NC}"

##############################################################
#				A U T E N T I C A C I Ó N
##############################################################

validateCertificate() {
	printf "\n\n${CYAN} ${BOLD}Validando certificados...${NC}\n\n"
	if [[ $(grep -lir "LB-PMO.pem" /etc/ssh/ssh_config) = "" ]]; then
		printf "${RED} -- ${BOLD}ERROR: No estas autenticado con el servidor, debes ejecutar la primera opción y autenticarte correctamente --${NC}\n"
		exit 1
	fi
}

if [[ $option != "1" && $option != "2" && $option != "3" && $option != "4" ]]; then
	printf "\n${RED}${BOLD} -- ERROR: Debe seleccionar una opción... --${NC}\n"
	exit 1
elif [[ $option = "1" ]]; then

	##############################################################
	#		V A L I D A C I O N E S   G E N E R A L E S
	##############################################################

	if [ $EUID -ne 0 ]; then
		printf "${RED}${BOLD} -- ERROR: Para acceder a esta opción debes ejecutar el script como root --${NC}\n"
		exit 1
	fi

	if [ ! -f LB-PMO.pem ]; then
		printf "${RED}${BOLD} -- ERROR: Debes ejecutar este script desde la misma ruta donde se encuentra el certificado LB-PMO.pem --${NC}\n"
		exit 1
	fi

	printf "${CYAN}${BOLD} -- Ingrese su usuario de linux: --${NC}\n"
	read user
	if [[ ! -d /home/$user || $user = "" ]]; then
		printf "${RED}${BOLD} -- ERROR: Ese no es tu usuario, por favor ingresa el correcto --${NC}\n"
		exit 1
	fi
	
	##############################################################
	#	  R E G I S T R A N D O   E L   C E R T I F I C A D O
	##############################################################

	if [ ! -d /home/$user/.certs ]; then
		mkdir /home/$user/.certs
	fi

	if [ ! -f /etc/ssh/ssh_config ]; then
		touch /etc/ssh/ssh_config
	fi

	cp LB-PMO.pem /home/$user/.certs/
	chmod 600 /home/$user/.certs/LB-PMO.pem
	chown -R $user:$user /home/$user/.certs

	echo -e "\n IdentityFile /home/$user/.certs/LB-PMO.pem" >> /etc/ssh/ssh_config

	printf "\n${GREEN}${BOLD} -- Autenticación exitosa --${NC}\n"
	exit

elif [[ $option = "3" || $option = "4"  ]]; then
	validateCertificate
	##############################################################
	#	  L I S T A D O   D E   R E P O S I T O R I O S
	##############################################################

	printf "${CYAN}\n ${BOLD}Buscando repositorios...${NF}\n\n${NC}"

	array=($(ssh $AMAZON ls /home/ubuntu/git))

	cont=0
	for item in ${array[*]}
	do
		printf "     [${CYAN}${BOLD}$cont${NC}] %s\n" $item
		let cont+=1
	done


	printf "\n ${CYAN}${BOLD}Seleccione un repositorio:${NC}\n"
	read repoSelec

    if [[ $repoSelec > ${#array[*]} || $repoSelec < 0 || !($repoSelec =~ $isNumber) || $repoSelec = "" ]]; then
		printf "${RED}${BOLD} -- ERROR: Debe seleccionar un repositorio... --${NC}\n"
		exit 1
	fi

   	repository=${array[$repoSelec]}
fi

##############################################################
#		N O M B R E   D E L   R E P O S I T O R I O
##############################################################

if [[ $repository = "" ]]; then
	validateCertificate
	printf "\n${CYAN}${BOLD} -- Introduce el nombre del respositorio a crear (${RED}${BOLD}sin .git${CYAN}${BOLD}): --${NC}\n"
	read newRepo
	if [[ $newRepo = "" ]]; then
		printf "\n${RED}${BOLD} -- ERROR: Debe ingresar el nombre del repositorio... --${NC}\n"
	    exit 1
	fi
	repository=$newRepo".git"
fi 

##############################################################
#		C O N F I G U R A C I Ó N   D E L   S E R V I D O R
##############################################################
if [[ $option = "2" ]]; then
	printf "\n\n${CYAN} ${BOLD}Creando repositorio remoto...${NC}\n\n"

	creatingRepo=$(ssh -t -t $AMAZON "
		if [ ! -d /home/ubuntu/git/$repository ]; then
			cd /home/ubuntu/git
			mkdir '$repository'

			cd '$repository'
			git --bare init
			git config core.sharedRepository true
		else
			echo 0
		fi	
	")
fi

##############################################################
#		C O N F I G U R A C I Ó N   D E L   C L I E N T E
##############################################################

if [[ $option = "2" || $option = "3" ]]; then

	if [[ $(grep "0" <<< $creatingRepo) ]]; then
		printf "\n${RED}${BOLD} -- ERROR: Ese nombre de repositorio ya esta utilizado... --${NC}\n"
		exit 1
	fi

	printf '\n${GREEN}${BOLD} -- EXITO: Repositorio creado!... --${NC}\n\n'
	printf "\n${CYAN}${BOLD} -- Creando repositorio local si no estaba creado... --${NC}\n\n"
	git init
	printf "\n${CYAN}${BOLD} -- Agregando archivos... --${NC}\n\n"
	git add *
	printf "\n${CYAN}${BOLD} -- Creando el commit... --${NC}\n\n"
	git commit -m "INITIAL COMMIT TO AWS'S SERVER"
	git remote remove aws
	git remote add aws "git+ssh://$AMAZON/home/ubuntu/git/$repository"
	printf "\n${CYAN}${BOLD} -- Cargando el estado del proyecto al: AWS's Server --${NC}\n\n"
	git push aws master
else
	printf "\n${CYAN}${BOLD} -- Clonando repositorio --${NC}\n\n"
	git clone git+ssh://$AMAZON/home/ubuntu/git/$repository
	cd ${repository:0:-4}
	git remote rename origin aws
fi
	printf "\n${GREEN}${BOLD} -- Listo, ahora puedes seguir trabajando en tu proyecto... --${NC}\n\n"
	printf "\n${CYAN}${BOLD} -- NOTA: tus pushs deben estar dirigidos a 'aws' (git push aws <branch>)... --${NC}\n\n"

exit
