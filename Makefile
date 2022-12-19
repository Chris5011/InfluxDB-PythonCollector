#Date: 19. Dec. 2022
#Author: Christoph (Chris5011) Dorner
#Desc: This Makefile aims to ease the installation of the service and changes the necessary parameters 

SmartmeterDir := /opt/Smartmeter

install-debs:
	sudo apt-get update
	sudo apt-get install python3 docker docker-compose -y
	pip3 install Flask==2.2.2 influxdb_client==1.33.0 requests==2.27.1

install: # install-debs
	echo "starting the installation of the Smartmeter-DataCollector"
	#Create Program-Directory
	sudo mkdir ${SmartmeterDir}
	#Copy all necessary files to this Directory	
	sudo cp ./EVN-InfluxDB-DataCollector.py ${SmartmeterDir}
	sudo cp ./docker-compose.yml ${SmartmeterDir}
	sudo cp ./initialize.sh ${SmartmeterDir}
	sudo cp ./.env ${SmartmeterDir}
	sudo cp ./Makefile ${SmartmeterDir}
	#Copy and Configure the Service
	sudo cp ./startContainer.sh ${SmartmeterDir}
	sudo cp ./stopContainer.sh ${SmartmeterDir}
	sudo cp ./Smartmeter.service ${SmartmeterDir}
	sudo sed -i 's#<INSTALLPATH>#${SmartmeterDir}#g' ${SmartmeterDir}/Smartmeter.service
	sudo cp ${SmartmeterDir}/Smartmeter.service /etc/systemd/system/Smartmeter.service
	sudo systemctl enable Smartmeter.service
	#Initialize the Compose-Container
	sudo sed -i 's#<INSTALLPATH>#${SmartmeterDir}#g' ${SmartmeterDir}/initialize.sh	
	sudo ${SmartmeterDir}/initialize.sh
	echo "Finished installing - the container can now be started using sudo systemctl start Smartmeter"

clean: 
	cd ${SmartmeterDir} ; docker-compose down
	sudo systemctl stop Smartmeter.service
	sudo systemctl disable Smartmeter.service
	sudo rm /etc/systemd/system/Smartmeter.service
	sudo rm -r ${SmartmeterDir}


