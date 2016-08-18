#!/bin/bash

##############################################################
#
# 					Creado por: Manuel Gil
#
# Este script permite:
#
# - Registrar el certificado de conexión con Amazon para 
# 	poder conectarse vía ssh al servidor sin necesidad de
#	autenticación. (Solo se ejecuta una vez)
#
#	NOTA: Este script debe ser ejecutado como -- root -- 
#		  desde la misma ruta donde se encuentra el  
#		  certificado -- LB-PMO.pem -- para su correcto 
#		  funcionamiento.
#
##############################################################

RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

##############################################################
#		V A L I D A C I O N E S   G E N E R A L E S
##############################################################

if [ $EUID -ne 0 ]; then
	printf "${RED} -- ERROR: Debes ejecutar este script como root --${NC}\n"
	exit 1
fi

if [ ! -f LB-PMO.pem ]; then
	printf "${RED} -- ERROR: Debes ejecutar este script desde la misma ruta donde se encuentra el certificado LB-PMO.pem --${NC}\n"
	exit 1
fi

printf "${CYAN} -- Ingrese su usuario de linux: --${NC}\n"
read user
if [ ! -d /home/$user ]; then
	printf "${RED} -- ERROR: Ese no es tu usuario, por favor ingresa el correcto --${NC}\n"
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

printf "${CYAN} -- Certificado registrado satisfactoriamente --${NC}\n"
exit