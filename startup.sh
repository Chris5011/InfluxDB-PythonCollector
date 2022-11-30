#!/bin/bash
#Author: Chris5011 (Christoph Dorner)
#Date: 23. Nov. 2022
#Desc: This Script is used to start the Smartmeter-Project (Database-Container, generate an API-Token and write it into the according Python-Script)

debug=1

smartmeterConfDir="/etc/smartmeter/"
influxConfFile="/mnt/InfluxData/conf/influx-configs"
influxDataStore="/mnt/InfluxData/DataStore/"

breakMaxTimeout=60
breakTimerCount=0

# Amount of InfluxDB instances detected on the host-system
influxInstanceCount=$(ps -ef | grep influxd | wc -l)


if [ ! $EUID -eq 0 ] ; then
	echo "Please execute this script with sudo!"
	exit 1
fi


if [ ! -d $smartmeterConfDir ] ; then 
	sudo mkdir $smartmeterConfDir
fi

if [ ! -f "$smartmeterConfDir.didrun" ] ; then 
	sudo touch "$smartmeterConfDir.didrun"
else
	echo "This script was already executed!"
	echo "If you just want to start the container use: docker-compose run influxdb"	
	exit 0;	
fi

echo "Starting up..."

docker-compose up > /dev/null 2>&1 &

if [ ! $? -eq 0 ] ; then
	echo "Problem during startup of initial container!";
	echo "Please check the Values in the .env-file!";
	sudo rm "$smartmeterConfDir.didrun"
	exit 2;
fi

echo "Waiting until the Docker has started..."
while :
do
	sleep 2
	if [ $(ps -ef | grep influxd | wc -l) -gt $influxInstanceCount ] ; then
		echo "Container has started!"
		break
	elif [ $breakTimerCount -ge $breakMaxTimeout ] ; then
		echo "Could not start the Container. It should not take longer than this."
		echo "If this Problem persists ensure that you have an internet-connection and change the breakMaxTimeout to a larger number and try again"
		exit 3
	fi

	breakTimerCount=$((breakTimerCount + 1))
done

TOKEN='EMPTY'
if [ -f $influxConfFile ] ; then

	TOKEN=$(cat /mnt/InfluxData/conf/influx-configs | grep -2 "\[default\]" | grep token | sed -e 's/token =//g' -e 's/\"//g' | tr -d '[:space:]')

else
	echo "Could not find the Config-File in: $influxConfFile!"
	echo "Terminating!"
	exit 4
fi

echo "Obtained Token: $TOKEN"
echo "Pasting into the EVN-InfluxDB-DataCollector.py ..."
sed -i "s/INFLUXTOKENPLACEHOLDER/$TOKEN/g" EVN-InfluxDB-DataCollector.py

if [ $debug -ge 1 ] ; then 
	#Start the Demo-API
	python ./demoApi.py > /dev/null 2>&1 &
	python ./EVN-InfluxDB-DataCollector.py > /dev/null 2>&1 &
fi


#Stop the Container for Testing: 
if [ $debug -gt 50 ] ; then 
	docker-compose stop influxdb > /dev/null 2>&1
fi





