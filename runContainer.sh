#!/bin/bash
#Author: Chris5011 (Christoph Dorner)
#Date: 02. Dec 2022
#Description: This Script is used to start the Container once it was created and initialized with the startup-script.

DataMountPoint=""
ConfMountPoint=""
DataSourceURL=""

debug=0

# Obtain the Data and Config-Path from the .env-File
while read -r line
do
	case $line in
		*"DataMountPoint"*)
			DataMountPoint=$(echo "$line" | sed 's/DataMountPoint=//g')
			;;
		*"ConfMountPoint"*)
			ConfMountPoint=$(echo "$line" | sed 's/ConfMountPoint=//g') 
			;;

		*"DataSourceURL"*)
			DataSourceURL=$(echo "$line" | sed 's/DataSourceURL=//g')
	esac
done < .env

if [ -z "$DataMountPoint" ] ; then
	echo "Could not determine the DataMountPoint, please check the .env file and make sure that the given directory exists!"
	exit 1
fi

if [ -u "$ConfMountPoint" ] ; then
	echo "Could not determine the ConfMountPoint, please check the .env file and make sure that the given directory exists!"
	exit 1
fi

docker run -d -p 8086:8086 --name smartmeter_influxdb -v $DataMountPoint:/var/lib/influxdb2 -v $ConfMountPoint/etc/influxdb2 influxdb:2.5.1

if [ ! $? -eq 0 ] ; then
	echo "Could not start the Container! Please check your config and try again"
	exit 2
fi
echo "Container started successfully!"

if [ $debug -gt 0 ] ; then
	echo "Launching the DemoAPI!"
	python demoAPI.py > /dev/null 2>&1 &
fi

echo "Launching the Collector"
python EVN-InfluxDB-DataCollector.py $DataSourceURL & #> /dev/null 2>&1 &

echo "Everything started, you can let it run now as it is"







