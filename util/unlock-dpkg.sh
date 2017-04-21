#!/bin/bash

echo "desbloqueando dpkg..."
sudo fuser -vki  /var/lib/dpkg/lock
echo "eliminando lock..."
sudo rm -f /var/lib/dpkg/lock
echo "Reparando posibles paquetes rotos..."
sudo dpkg --configure -a
echo "limpiando..."
sudo apt-get autoremove
echo "Listo!"
