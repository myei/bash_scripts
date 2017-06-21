#!/bin/bash
##############################################################
#
# 										Creado por: Manuel Gil
#
# Este script permite:
# 
# - Generación de DNS
# 
# - Modifica y crea los archivos necesarios para la correcta
# 	configuración del sitio
# 
# - Funciona bajo argumentos
# 		- n, --name
# 		- t, --target
# 
# 														v1.0
##############################################################

# C O L O R S
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\e[95m'
WHITE='\e[97m'
YELLOW='\e[93m'
NC='\033[0m'

# F O N T S
BOLD='\e[1m'
NF='\e[0m'
BLINK='\e[5m'
I='\e[3m'
S='\e[4m'

# C O N F I G U R A C I Ó N
SCRIPT_NAME='dns-generate'
BIND_PATH='/etc/bind/'
NAMED_CONF_LOCAL=$BIND_PATH'named.conf.local'
HOST=$(hostname)

#############################################################
# 				A R G U M E N T O S
#############################################################

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -t|--target)
    TARGET="$2"
    shift
    ;;
    -n|--name)
    DNS="$2"
    shift
    ;;
    *)
    ;;
esac
shift
done

sendMsg() {
	if [[ $1 = "ERROR" ]]; then
		color=$RED
	elif [[ $1 = "INFO" ]]; then
		color=$CYAN
	elif [[ $1 = "WARN" ]]; then
		color=$YELLOW
	elif [[ $1 = "GOOD" ]]; then
		color=$GREEN
	else
		color=$WHITE
	fi

	printf "\n${color}${BOLD} $2${NC}\n\n"

	if [[ $1 = "ERROR" ]]; then
		exit 1
	fi
}


confirm() {
	printf " $1${BOLD}$2$1${BOLD}? [Y/n]: ${WHITE}"
	read -n 1 confirm
	printf "${NC}\n"

	if [[ $confirm != "Y" && $confirm != "y" && $confirm != "" ]]; then
		sendMsg ERROR "\n Operación abortada..."
	fi
}

#############################################################
# 				V A L I D A N D O
#############################################################

if [[ ${#DNS} -eq 0 || ${#TARGET} -eq 0 ]]; then
	printf "error: invalids args \n\n"

	printf "${SCRIPT_NAME} usage: ${SCRIPT_NAME} [ ARGS ] \n\n"

	printf "	-n, --name: 	Name of the dns \n\n"	

	printf "	-t, --target: 	Target ip \n\n"	

	exit
elif [[ $1 = "-i" || $1 = "--install" ]]; then
	if [[ $(echo $(readlink -f $0) | grep '/usr/bin/') = '' ]]; then
		if [[ -f /usr/bin/$SCRIPT_NAME || -L /usr/bin/$SCRIPT_NAME ]]; then
			sudo rm /usr/bin/$SCRIPT_NAME
		fi
		
		sudo cp $(readlink -f $0) /usr/bin/$SCRIPT_NAME

		echo -e "[${GREEN}${BOLD}OK${NC}] install script"
	else
		echo -e "[${RED}${BOLD}ERROR${NC}] install script: already installed"
	fi

	exit
fi

confirm $YELLOW "\nEstá seguro de generar ->${CYAN}${BOLD} ${DNS} ${YELLOW} con destino ->${CYAN}${BOLD} ${TARGET} "

#############################################################
# 		C O N F I G U R A N D O   E L   B I N D 
#############################################################

echo -e 'zone "'$DNS'" {
        type master;
        file "/etc/bind/db.'$DNS'";
        allow-update{key "rndc-key"; };
        notify no;
};' >> $NAMED_CONF_LOCAL

echo '
$ORIGIN .
$TTL 604800 ; 1 week
'$DNS' IN SOA '$HOST'.'$DNS'. root.'$DNS'. (
                                79 ; serial
                                604800 ; refresh (1 week)
                                86400 ; retry (1 day)
                                2419200 ; expire (4 weeks)
                                604800 ; minimum (1 week)
                                )
                        NS      '$DNS'.
                        A       '$TARGET'
                        AAAA    ::1
$ORIGIN '$DNS'.
$TTL 1800       ; 30 minutes' > $BIND_PATH'db.'$DNS

#############################################################
# 		E S T A D O   F I N A L
#############################################################

sendMsg GOOD "DNS generado exitosamente"

sendMsg INFO "Estatus de la zona:"

named-checkzone $DNS $BIND_PATH'db.'$DNS

sendMsg INFO "Estatus del servicio después de crear la zona:"

/etc/init.d/bind9 restart