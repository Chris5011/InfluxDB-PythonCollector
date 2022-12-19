#!/bin/bash
#Author: Chris5011 (Christoph Dorner)
#Date: 23. Nov. 2022
#Desc: This Script is used to start the Smartmeter-Project (Database-Container, generate an API-Token and write it into the according Python-Script)

debug=0

smartmeterConfDir="/etc/smartmeter/"
influxDataStore=""
influxConfDir=""
influxConfFile="/influx-configs"


breakMaxTimeout=120
breakTimerCount=0

# Amount of InfluxDB instances detected on the host-system
influxInstanceCount=$(ps -ef | grep influxd | wc -l)

function testResult(){
	errCode=$1
	cmd=$2

	if [ $errCode -eq 0 ] ; then
		return 0
	else
		echo "Command $cmd finished with errors - abort!"
		exit 1
	fi
}


function checkAndSetPermissions() {
	local pathToDir=$1

	echo "$pathToDir"

	# Create the Datastore-Directory with all parents in case it does not exist (and beg for forgiveness)
	mkdir -p $pathToDir #> /dev/null 2>&1

	# Check the Mounting-Directories and set the according permissions
	if [ -d $pathToDir ] ; then
		chown nobody:nogroup -R $pathToDir
		testResult $? 'chown'
			
		chmod 2766 -R $pathToDir
	else 
		echo "Directory $pathToDir could not be read locally!"
		exit 1
	fi
}



if [ ! $EUID -eq 0 ] ; then
	echo "Please execute this script with sudo!"
	exit 1
fi


pip3 install -r requirements.txt > /dev/null 2>&1 

if [ $? -ne 0 ] ; then
	echo "Could not load the Python-Requirements."
	echo "Try installing them yourself! (requirements.txt)"
	exit 1
fi

# Obtain the Data and Config-Path from the .env-File
while read -r line
do
	case $line in
		*"DataMountPoint"*)
			influxDataStore=$(echo "$line" | sed 's/DataMountPoint=//g')
			#influxDataStore=$line
			;;
		*"ConfMountPoint"*)
			influxConfDir=$(echo "$line" | sed 's/ConfMountPoint=//g')
			;;
	esac
done < .env


echo "Found data directory path: $influxDataStore"
echo "Found config directory path: $influxConfDir"

checkAndSetPermissions $influxDataStore
checkAndSetPermissions $influxConfDir

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
	if [ $(ps -ef | grep influxd | wc -l) -gt $influxInstanceCount ] ; then
		echo "Container has started!"
		break
	elif [ $breakTimerCount -ge $breakMaxTimeout ] ; then
		echo "Could not start the Container. It should not take longer than this."
		echo "If this Problem persists ensure that you have an internet-connection and change the breakMaxTimeout to a larger number and try again"
		exit 3
	fi

	sleep 1
	breakTimerCount=$((breakTimerCount + 1))
done

#Give the Container some time to fully start:
sleep 20

TOKEN='EMPTY'
influxConfFilePath="$influxConfDir$influxConfFile"
echo "InfluxConfFilePath: $influxConfFilePath"

if [ -f $influxConfFilePath ] ; then

	TOKEN=$(cat $influxConfFilePath | grep -2 "\[default\]" | grep token | sed -e 's/token =//g' -e 's/\"//g' | tr -d '[:space:]')

else
	echo "Could not find the Config-File in: $influxConfFilePath !"
	echo "Terminating!"
	exit 4
fi

echo "Obtained Token: $TOKEN"
echo "Pasting into the EVN-InfluxDB-DataCollector.py ..."
sed -i "s/INFLUXTOKENPLACEHOLDER/$TOKEN/g" EVN-InfluxDB-DataCollector.py

#Stop the Compose-Container again
docker-compose stop influxdb > /dev/null 2>&1

#if [ $debug -ge 1 ] ; then 
#	#Start the Demo-API
#	python demoAPI.py & #> /dev/null 2>&1 &
#fi
#
#python EVN-InfluxDB-DataCollector.py & #> /dev/null 2>&1 &
#
##Stop the Container for Testing: 
#if [ $debug -gt 50 ] ; then 
#	docker-compose stop influxdb > /dev/null 2>&1
#fi

