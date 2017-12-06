#!/bin/bash

SERVER=$(hostname)
EMAIL='manuelyeixon@gmail.com'

log=/var/log/overload.log
cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
memory=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

if [[ ${#} == 0 ]]; then
	echo "Debe especificar el porcentaje base a monitorear..."
	exit 1
fi

if [[ ${cpu%.*} -gt $1 ]]; then
	echo "`date -u +%Y-%m-%dT%H:%M:%S` cpu usage: $cpu%" >> $log
	echo "`date -u +%Y-%m-%dT%H:%M:%S` cpu usage: $cpu%" | $(mail -s "WARN ${SERVER}" $EMAIL)
fi

if [[ ${memory%.*} -gt $1 ]]; then
	echo "`date -u +%Y-%m-%dT%H:%M:%S` memory usage: $memory%" >> $log

	if [[ ${memory%.*} -gt 80 ]]; then
		service apache2 stop
		sleep 5
		service apache2 start

		echo "`date -u +%Y-%m-%dT%H:%M:%S` memory usage: $memory%... Apache fue reiniciado" | $(mail -s "WARN ${SERVER}" $EMAIL)

		exit
	fi
	
	echo "`date -u +%Y-%m-%dT%H:%M:%S` memory usage: $memory%" | $(mail -s "WARN ${SERVER}" $EMAIL)
fi
