#!/bin/bash

##############################################################
#
# 					Creado por: Manuel Gil
#
# Este script permite:
#
# - Registrar el certificado de conexión con Amazon para 
# 	poder conectarse vía ssh al servidor sin necesidad de
#	autenticación
#
#	NOTA: Este script debe ser ejecutado desde la misma ruta
#		  donde se encuentra el certificado LB-PMO.pem para 
#		  su correcto funcionamiento
#
##############################################################

RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ ! -f LB-PMO.pem ]; then
	printf "${RED} -- ERROR: Debes ejecutar este script desde la misma ruta donde se encuentra el certificado LB-PMO.pem --${NC}\n"
	exit 1;
fi

if [ ! -d /etc/ssh/certs ]; then
	mkdir /etc/ssh/certs
fi

if [ ! -f /etc/ssh/ssh_config ]; then
	touch /etc/ssh/ssh_config
fi

cp LB-PMO.pem /etc/ssh/certs/
chmod 600 /etc/ssh/certs/LB-PMO.pem
echo -e "\nIdentityFile /etc/ssh/certs/LB-PMO.pem" >> /etc/ssh/ssh_config

printf "${CYAN} -- Certificado registrado satisfactoriamente --${NC}\n"
exit