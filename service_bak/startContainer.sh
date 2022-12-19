#!/bin/bash
#Date: 19. Dec. 2022
#Author: Christoph (Chris5011) Dorner
#Desc: This script is used to start the InfluxDB Container on system-startup

if [ $(docker-compose ps | grep influxdb | grep Up | wc -l) -eq 1 ] ; then
	echo "The container is already running!"
	exit 1 
fi

docker-compose start influxdb
