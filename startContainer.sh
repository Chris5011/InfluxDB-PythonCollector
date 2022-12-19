#!/bin/bash
#Date: 19. Dec. 2022
#Author: Christoph (Chris5011) Dorner
#Desc: This script is used to start the InfluxDB Container on system-startup

docker-compose ps

if [ $(docker-compose ps | grep influxdb | grep Up | wc -l) -gt 1 ] ; then
	echo "The container is already running!"
	exit 1 
fi
docker-compose start | tee -a /var/log/Smartmeter.log
