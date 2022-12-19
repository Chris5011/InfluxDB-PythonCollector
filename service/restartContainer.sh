#!/bin/bash
#Date: 19. Dec. 2022
#Author: Christoph (Chris5011) Dorner
#Desc: This script is used to start the InfluxDB Container on system-startup

if [ $(docker-compose ps | grep influxdb | grep Up | wc -l) -eq 1 ] ; then
	echo "The container is running - restarting!"
	docker-compose stop influxdb
	docker-compose start influxdb
else
	echo "The container seems to be stopped - starting!"
	docker-compose start influxdb
fi

