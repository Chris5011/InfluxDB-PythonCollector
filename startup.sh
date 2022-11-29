#!/bin/bash
#Author: Chris5011 (Christoph Dorner)
#Date: 23. Nov. 2022
#Desc: This Script is used to start the Smartmeter-Project (Database-Container, generate an API-Token and write it into the according Python-Script)

debug=1

if [ ! -d /etc/smartmeter ] ; then 
	sudo mkdir /etc/smartmeter
fi

if [ ! -f /etc/smartmeter/.didrun ] ; then 
	sudo touch /etc/smartmeter/.didrun
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
	sudo rm /etc/smartmeter/.didrun
	exit 1;
fi

#echo "Waiting 20 Seconds until the Container has started!"
#sleep 20

echo "Waiting until the Docker has started..."
while :
do
	
	if [ -f /etc/smartmeter/started ] ; then
		echo "container has started!"
		break
	fi
done






#Obtaining a Token from the Docker-File
COMPOSE=`docker-compose exec influxdb /bin/bash -c "influx auth create --all-access | grep admin"`
if [[ `echo "$COMPOSE" | wc -l` -ne 1 ]]
then
	echo "Failed to obtain token, try to run this script again"
	echo "Compose debug: $COMPOSE"
	exit 2;
else
	TOKEN=`echo "$COMPOSE" | grep 'admin' | awk '{ print $2; }'`
	echo "Obtained Token: $TOKEN"
fi


#Priming the Python-Script with the Token
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





