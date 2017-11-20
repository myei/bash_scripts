#!/bin/bash

log=/var/log/overload.log
cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
memory=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

if [[ ${#} == 0 ]]; then
	echo "Debe especificar el porcentaje base a monitorear..."
	exit 1
fi

if [[ ${cpu%.*} -gt $1 ]]; then
	echo "`date -u +%Y-%m-%dT%H:%M:%S` cpu usage: $cpu%" >> $log
	echo "`date -u +%Y-%m-%dT%H:%M:%S` cpu usage: $cpu%" | $(mail -s "WARN DED779" manuelyeixon@gmail.com)
fi

if [[ ${memory%.*} -gt $1 ]]; then
	echo "`date -u +%Y-%m-%dT%H:%M:%S` memory usage: $memory%" >> $log
	echo "`date -u +%Y-%m-%dT%H:%M:%S` memory usage: $memory%" | $(mail -s "WARN DED779" manuelyeixon@gmail.com)
fi
