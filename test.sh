#!/bin/bash

if [[ $(grep -lir "IdentityFile /home/mgil/certs/LB-PMsO.pem" /etc/ssh/ssh_config) = "" ]]; then
	echo "si"
else
	echo "no"
fi