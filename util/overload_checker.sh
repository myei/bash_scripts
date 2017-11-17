#!/bin/bash

log=/var/log/overload.log
cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
memory=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

if [[ $cpu > 90 ]]; then
	echo "cpu usage: $cpu%" >> $log
fi

if [[ $memory > 90 ]]; then
	echo "memory usage: $memory%" >> $log
fi
