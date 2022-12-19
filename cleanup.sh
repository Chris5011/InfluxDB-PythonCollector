#!/bin/bash
#Author: Chris5011
#Date: 	30. Nov. 2022
#Desc: 	This is a development-script for me which cleans the /etc/smartmeter dir
#	and also deletes the docker-compose instance as well as the images for a fresh start.

rmImage=2

if [ $EUID -ne 0 ] ; then
	echo "Please execute this script with sudo!"
	exit 1
fi


rm /etc/smartmeter/.didrun > /dev/null 2>&1
docker-compose down > /dev/null 2>&1

while :
do
	if [ $(ps -ef | grep influxd | wc -l) -eq 1 ] ; then
		echo "Container has stopped!"
		break
	fi
	sleep 2
done




docker container rm $(docker container ls -aq) > /dev/null 2>&1

if [ $rmImage -ge 1 ] ; then	
	docker volume rm $(docker volume ls -q) > /dev/null 2>&1
	docker image rm $(docker image ls -q) > /dev/null 2>&1
fi

if [ $rmImage -ge 2 ] || [ $rmImage -lt 0 ] ; then
	pkill -f demoAPI.py > /dev/null 2>&1
	pkill -f EVN-InfluxDB-DataCollector.py > /dev/null 2>&1
	rm EVN-InfluxDB-DataCollector.py
	cp EVN-InfluxDB-DataCollector.py.bak EVN-InfluxDB-DataCollector.py	
fi


echo "Finished cleaning-up"
