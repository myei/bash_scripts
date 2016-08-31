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
# - Eliminar un repositorio remoto
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
S='\e[4m'

AMAZON='ubuntu@54.204.107.45'
isNumber="^-?[0-9]+([.][0-9]+)?$"
repoSelected=""

##############################################################
#						M E N Ú
##############################################################
clear
printf "\n 	   Bienvenido al ${BOLD}${PURPLE}LorebiGit${NF}\n\n"
printf " ${CYAN}${BOLD}Que acción desea realizar?${NF} \n\n${NC}"
printf "  [${CYAN}${BOLD}1${NC}] Autenticarme con el Servidor [${RED}${BOLD}root${NC}] (${BLUE}${BOLD}Sólo la primera vez${NC})\n"
printf "  [${CYAN}${BOLD}2${NC}] Crear repositorio y enlazar \n"
printf "  [${CYAN}${BOLD}3${NC}] Clonar repositorio \n"
printf "  [${CYAN}${BOLD}4${NC}] Eliminar repositorio \n"

printf "\n${CYAN}${BOLD} Opción: ${NC}${BOLD}"
read -n 1 option

##############################################################
#				A U T E N T I C A C I Ó N
##############################################################

validateCertificate() {
	printf "\n\n${CYAN} ${BOLD}Validando certificados...${NC}\n"
	if [[ $(grep -lir "LB-PMO.pem" /etc/ssh/ssh_config) = "" ]]; then
		printf "${RED} ${BOLD}ERROR: No estas autenticado con el servidor, debes ejecutar la primera opción y autenticarte correctamente${NC}\n\n"
		exit 1
	fi
	printf "\n${GREEN}${BOLD} OK...${NC}\n"
}

if [[ $option != "1" && $option != "2" && $option != "3" && $option != "4" ]]; then
	printf "\n${RED}${BOLD} ERROR: Debe seleccionar una opción...${NC}\n\n"
	exit 1
elif [[ $option = "1" ]]; then

	##############################################################
	#		V A L I D A C I O N E S   G E N E R A L E S
	##############################################################

	if [ $EUID -ne 0 ]; then
		printf "\n\n${RED}${BOLD} ERROR: Para acceder a esta opción debes ejecutar el script como root${NC}\n\n"
		exit 1
	fi

	if [ ! -f LB-PMO.pem ]; then
		printf "\n\n${RED}${BOLD} ERROR: Debes ejecutar este script desde la misma ruta donde se encuentra el certificado LB-PMO.pem ${NC}\n\n"
		exit 1
	fi

	printf "\n\n${CYAN}${BOLD} Ingrese su usuario de linux:${NC} "
	read -p "" user
	if [[ ! -d /home/$user || $user = "" ]]; then
		printf "\n${RED}${BOLD} ERROR: Ese no es tu usuario, por favor ingresa el correcto${NC}\n\n"
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

	printf "\n${GREEN}${BOLD} Autenticación exitosa...${NC}\n"
	exit

elif [[ $option = "3" || $option = "4" ]]; then
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


	printf "\n ${CYAN}${BOLD}Seleccione un repositorio:${NC} "
	read -p "" repoSelec

    if [[ $repoSelec > ${#array[*]} || $repoSelec < 0 || !($repoSelec =~ $isNumber) || $repoSelec = "" ]]; then
		printf "\n${RED}${BOLD} ERROR: Debe seleccionar un repositorio...${NC}\n\n"
		exit 1
	fi

   	repository=${array[$repoSelec]}
fi

##############################################################
#		N O M B R E   D E L   R E P O S I T O R I O
##############################################################

if [[ $repository = "" ]]; then
	validateCertificate
	printf "\n${CYAN}${BOLD} Introduce el nombre del respositorio a crear (${RED}${BOLD}sin .git${CYAN}${BOLD}):${NC} "
	read -p "" newRepo
	if [[ $newRepo = "" ]]; then
		printf "\n${RED}${BOLD} ERROR: Debe ingresar el nombre del repositorio...${NC}\n\n"
	    exit 1
	fi
	repository=$newRepo".git"
fi 

if [[ $option = "2" ]]; then

	##############################################################
	#		C O N F I G U R A C I Ó N   D E L   S E R V I D O R
	##############################################################

	printf "\n${CYAN} ${BOLD}Creando repositorio remoto...${NC}\n\n"

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

	##############################################################
	#		C O N F I G U R A C I Ó N   D E L   C L I E N T E
	##############################################################

	if [[ $(grep "0" <<< $creatingRepo) ]]; then
		printf "\n${RED}${BOLD} ERROR: Ese nombre de repositorio ya esta utilizado...${NC}\n\n"
		exit 1
	fi

	printf "\n${GREEN}${BOLD} EXITO: Repositorio creado!...${NC}\n\n"
	printf "\n${CYAN}${BOLD} Creando repositorio local si no estaba creado...${NC}\n\n"
	git init
	printf "\n${CYAN}${BOLD} Agregando archivos...${NC}\n\n"
	git add *
	printf "\n${CYAN}${BOLD} Creando el commit...${NC}\n\n"
	git commit -m "INITIAL COMMIT TO AWS'S SERVER"
	git remote remove aws
	git remote add aws "git+ssh://$AMAZON/home/ubuntu/git/$repository"
	printf "\n${CYAN}${BOLD} Cargando el estado del proyecto al: AWS's Server${NC}\n\n"
	git push aws master

elif [[ $option = "3" ]]; then

	printf "\n${CYAN}${BOLD} Clonando repositorio...${NC}\n\n"
	git clone git+ssh://$AMAZON/home/ubuntu/git/$repository
	cd ${repository:0:-4}
	git remote rename origin aws

elif [[ $option = "4" ]]; then

	ssh -t -t $AMAZON "
		if [ -d /home/ubuntu/git/${array[$repoSelec]} ]; then
			sudo rm -r /home/ubuntu/git/${array[$repoSelec]}
		fi	
	"
	printf "\n${GREEN} ${BOLD}Repositorio eliminado... ${NC}\n\n"
	exit

fi

	printf "\n${GREEN}${BOLD} Listo, ahora puedes seguir trabajando en tu proyecto...${NC}\n\n"
	printf "\n${CYAN}${BOLD} NOTA: tus pushs deben estar dirigidos a 'aws' (git push aws <branch>)...${NC}\n\n"

exit