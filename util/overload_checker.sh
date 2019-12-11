#!/bin/bash
# Basic script for installing the basics packages for Arch based distros
# 
# usage: overload-checker.sh [PERCENTAGE]
#
#                                                                  @myei


SERVER=$(hostname)
EMAIL='email@email.com'

log=/var/log/overload.log
cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
memory=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

[[ -z $1 ]] && echo "usage: overload-checker.sh [PATH]" && exit 1


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

		echo "`date -u +%Y-%m-%dT%H:%M:%S` memory usage: $memory%... apache2 restarted" | $(mail -s "WARN ${SERVER}" $EMAIL)

		exit
	fi
	
	echo "`date -u +%Y-%m-%dT%H:%M:%S` memory usage: $memory%" | $(mail -s "WARN ${SERVER}" $EMAIL)
fi
