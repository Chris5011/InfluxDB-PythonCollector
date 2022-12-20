#!/bin/bash
#Date: 20. Dec. 2022
#Author: Christoph (Chris5011) Dorner
#Desc: This script is used to stop the DataCollector (Used for the Service as stopping mechanism). 

echo "Stopping the Data-Collector..."
runningCount=$(ps -ef | grep EVN-InfluxDB-DataCollector.py)

if [ $runningCount -gt 1 ] ; then
	pkill -f EVN-InfluxDB-DataCollector.py
fi
