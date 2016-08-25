#!/bin/bash

##############################################################
# Creado por: Manuel Gil
#
# Script sencillo para crear un repositorio Git autocompartido
#
##############################################################

cd /home/git
echo "-- Introduce el nombre del respositorio a crear (sin .git): --"
read repository

if [ "$repository" != "" ]; then
        mkdir "$repository.git"
        cd "$repository.git"
        git --bare init
        git config core.sharedRepository true
        echo "-- EXITO: Repositorio creado!... --"
else
        echo "!--- ERROR: Debe ingresar el nombre del repositorio... ---!"
fi

exit
