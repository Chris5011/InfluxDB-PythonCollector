#!/usr/bin/make
#Date: 19. Dec. 2022
#Author: Christoph (Chris5011) Dorner
#Desc: This Makefile aims to ease the installation of the service and changes the necessary parameters 

include .env
export

install-debs:
	sudo apt-get update
	sudo apt-get install python3 docker docker-compose -y
	pip3 install Flask==2.2.2 influxdb_client==1.33.0 requests==2.27.1

install: install-debs
	@echo "starting the installation of the Smartmeter-DataCollector"
	#Create Program-Directory
	sudo mkdir ${INSTALL_PATH}
	#Copy all necessary files to this Directory	
	sudo cp ./EVN-InfluxDB-DataCollector.py ${INSTALL_PATH}
	sudo cp ./docker-compose.yml ${INSTALL_PATH}
	sudo cp ./initialize.sh ${INSTALL_PATH}
	sudo cp ./.env ${INSTALL_PATH}
	sudo cp ./Makefile ${INSTALL_PATH}
	#Copy and Configure the Service
	sudo cp ./startContainer.sh ${INSTALL_PATH}
	sudo cp ./stopContainer.sh ${INSTALL_PATH}
	sudo cp ./Smartmeter.service ${INSTALL_PATH}
	sudo sed -i 's#<INSTALLPATH>#${INSTALL_PATH}#g' ${INSTALL_PATH}/Smartmeter.service
	sudo cp ${INSTALL_PATH}/Smartmeter.service /etc/systemd/system/Smartmeter.service
	sudo systemctl enable Smartmeter.service
	#Copy and Configure the Collector-Service
	sudo cp ./startCollector.sh ${INSTALL_PATH}
	sudo cp ./stopCollector.sh ${INSTALL_PATH}
	sudo cp ./Smartmeter-Collector.service ${INSTALL_PATH}
	sudo sed -i 's#<INSTALLPATH>#${INSTALL_PATH}#g' ${INSTALL_PATH}/Smartmeter-Collector.service
	sudo sed -i 's#<INSTALLPATH>#${INSTALL_PATH}#g' ${INSTALL_PATH}/startCollector.sh
	sudo sed -i 's#<INSTALLPATH>#${INSTALL_PATH}#g' ${INSTALL_PATH}/stopCollector.sh
	sudo cp ${INSTALL_PATH}/Smartmeter-Collector.service /etc/systemd/system/Smartmeter-Collector.service
	sudo systemctl enable Smartmeter-Collector.service
	#Initialize the Compose-Container
	sudo sed -i 's#<INSTALLPATH>#${INSTALL_PATH}#g' ${INSTALL_PATH}/initialize.sh	
	sudo ${INSTALL_PATH}/initialize.sh
	@echo "Finished installing - the container can now be started using sudo systemctl start Smartmeter"

clean: 
	cd ${INSTALL_PATH} ; docker-compose down
	sudo systemctl stop Smartmeter.service
	sudo systemctl disable Smartmeter.service
	sudo systemctl stop Smartmeter-Collector.service
	sudo systemctl disable Smartmeter-Collector.service
	sudo rm /etc/systemd/system/Smartmeter.service
	sudo rm /etc/systemd/system/Smartmeter-Collector.service
	sudo rm -r ${INSTALL_PATH}
	sudo rm /etc/smartmeter/.didrun

#Does not remove orphans
purge: clean
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	sudo rm -r ${DataMountPoint}
	sudo rm -r ${ConfMountPoint}
