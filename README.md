# InfluxDB-PythonCollector
This repository contains the necessary tools to read the data from a HTTP-JSON API for the EVN-SmartMeter by Netz-Niederösterreich and to save it periodically to an InfluxDB.

## Included files: 
### demoAPI.py
This file emulates the API for the SmartMeter for testing purposes.
It provides a HTTP-Endpoint at http://localhost:5000/metrics where the JSON-Content can be obtained 
The values are random-generated, excluding the Timestamp which is the current time, and the 'uptime'-field, which is static

### docker-compose.yml
This is the file to create the Docker-Container for InfluxDB. Change the settings accordingly for your Use-Case

### EVN-InfluxDB-DataCollector.py
This Script queries the Data-API (real or the demoAPI) periodically, formats the data to use the according names and units and saves it in the InfluxDB.
There are a few settings to change in this file. The most important is the API-Token, which must be created in the InfluxDB-Webinterface to allow writing to the "Stromzähler"-Bucket.
The default-polling interval is set to 5 seconds, which can be changed to ones own needs.

### stromzähler.json
This file contains the code for a Demo-Dashboard which can be imported into the InfluxDB.

### requirements.txt
Contains the necessary python-dependencies

## Installation

### Prerequisites
Make sure Docker, Docker-Compose and Python ≥ 3.10 are installed on the system

### Usage
1. Install the necessary python reqirements with `pip3 install -r requirements.txt`
2. Change the settings in the docker-compose.yml file accordingly to your own needs. (Most importantly, change the password)
3. Create the container with `docker-compose up` 
4. Log into the webinterface using `http://<container-ip>:8086/` with the admin-credentials configured in the docker-compose.yml file
5. Create an API-Token for the "Stromzähler"-Bucket in the "Load Data" --> "API Tokens" Menu. \
  5.1. For better security, create an Read-/Write Token, with only write-permissions for the "Stromzähler"-Bucket. \
  5.2. Copy the newly generated API-Token\
6. Edit the EVN-InfluxDB-DataCollector.py file \
  6.1. Set the Admin-Token in the "API_TOKEN" variable \
  6.2. Change the "INFLUX_URL" and the "DATA_SOURCE" Variables to the according URLs. \
7. (If the Bucket, or the Org-Name were changed in the Docker-Compose.yml file, change them here accordingly)
8. (If the API should be tested with the DemoAPI, start it first with `python3 demoAPI.py &`)
9. Start the Collector with `python3 EVN-InfluxDB-DataCollector.py &`
10. If everything worked to plan, there should be a message "Starting the collection of Data" with no error on the console.

## Importing the Dashboard
To import the Demo-Dashboard, go to "Dashboards" --> "+ Create Dashboard" --> "Import Dashboard"
There, select the "Stromzähler.json" file and click "Import JSON as Dashboard"

Now a Dashboard called "Stromzähler" should be present. 

