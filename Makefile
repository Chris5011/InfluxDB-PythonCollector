#Date: 19. Dec. 2022
#Author: Christoph (Chris5011) Dorner
#Desc: This Makefile aims to ease the installation of the service and changes the necessary parameters 

SmartmeterDir := /opt/Smartmeter

install:
	echo "starting the installation of the Smartmeter-DataCollector"
	sudo mkdir ${SmartmeterDir}	
	sudo mv ./EVN-InfluxDB-DataCollector.py ${SmartmeterDir}
	sudo mv ./EVN-InfluxDB-DataCollector.py.bak ${SmartmeterDir}
	sudo mv ./docker-compose ${SmartmeterDir}
	sudo mv ./initialize.sh ${SmartmeterDir}
	sudo mv ./runContainer.sh ${SmartmeterDir}
	sudo mv ./requirements.txt ${SmartmeterDir}
	sudo mv ./cleanup.sh ${SmartmeterDir}
	sudo mv ./.env ${SmartmeterDir}
	#Configure the Service
	sudo mv ./service ${SmartmeterDir}
	sudo sed -i 's#<INSTALLPATH>#${SmartmeterDir}#g' ${SmartmeterDir}/service/Smartmeter.service
	sudo mv ${SmartmeterDir}/service/Smartmeter.Server /etc/systemd/system/Smartmeter.service
	sudo systemctl enable Smartmeter.service
	#Initialize the Compose-Container
	sudo ${SmartmeterDir}/initialize.sh
	
	echo "Finished installing - the container can now be started using sudo systemctl start Smartmeter"

run: 
	sudo systemctl start Smartmeter

clean: 
	echo "Cleaning up everything"
	sudo ./cleanup.sh



