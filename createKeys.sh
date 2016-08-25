#! /bin/bash

##############################################################
# Creado por: Manuel Gil
#
# Script sencillo para generación de claves rsa y autenticación
# automática con el servidor:
#       - root@190.121.226.235:2224
#
##############################################################


echo "-- Generando keys --"
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

echo "-- Autenticando acceso con el Ranchito's Server (Deberá ingresar la clave del servidor --"
ssh-copy-id root@190.121.226.235 -p 2224
echo "-- Listo! Ya tienes acceso sin autenticación al Ranchito's Server --"
exit
