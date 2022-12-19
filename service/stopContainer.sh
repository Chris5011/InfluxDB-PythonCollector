#!/bin/bash
#Date: 19. Dec. 2022
#Author: Christoph (Chris5011) Dorner
#Desc: This script is used to stop the InfluxDB Container on system-shutdown

if [ $(docker-compose ps | grep influxdb | grep Exit | wc -l) -eq 1 ] ; then
	echo "The container is not running!"
	exit 1 
fi

docker-compose stop influxdb
