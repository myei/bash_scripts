#!/bin/bash

##############################################################
# Creado por: Manuel Gil
#
# Script sencillo para crear y conectar nuestro proyecto con
# un repositorio existente en el serivdor:
# 	- 190.121.226.235:2224
#
##############################################################


echo "-- Ingrese el nombre del repositorio remoto (sin .git) --"
read repo

if [ "$repo" != "" ]; then

	echo "-- Creando repositorio local si no estaba creado... --"
	git init
	echo "-- Agregando archivos... --"
	git add *
	echo "-- Creando el commit... --"
	git commit -m "INITIAL COMMIT TO RANCHITO'S SERVER"
	git remote add ranchito "git+ssh://root@190.121.226.235:2224/home/git/$repo.git"
	echo "-- Cargando el estado del proyecto al: Ranchito's Server --"
	git push ranchito master
	echo "-- Listo, ahora puedes seguir trabajando en tu proyecto... --"

else
	echo "!--- ERROR: Debe ingresar el nombre del repositorio... ---!"
fi

exit
