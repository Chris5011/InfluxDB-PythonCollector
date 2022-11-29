import requests
import json
import time
from requests import RequestException
from datetime import datetime
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

#URL to the JSON-Data-Source
DATA_SOURCE = 'http://127.0.0.1:5000/metrics'

#URL to the Influx-Instance
INFLUX_URL    = 'http://localhost:8086'
# !!! You must generate an API token from the "API Tokens Tab" in the UI !!!    
INFLUX_TOKEN  = 'INFLUXTOKENPLACEHOLDER'
# Name of the Influx-Organization
INFLUX_ORG    = 'MyOrg'
#Name of the Influx-Bucket to write to
INFLUX_BUCKET = 'Stromzähler'

#Fields which should be parsed and added to the Influx-Database
jsonFields = ['timestamp', '1.8.0', '2.8.0', '1.7.0', '2.7.0', '32.7.0', '52.7.0', '72.7.0', '31.7.0', '51.7.0', '71.7.0', '13.7.0', 'uptime']

#Format of the Timestamp from the API: 
TIME_FORMAT = '%Y:%m:%dT%H:%M:%S'

#Timer to Poll the API and write data: 
TIMEOUT = 5


def get_data_from_api(url='localhost:5000/metrics'):
    
    try:
        r = requests.get(url)
        if(r.status_code == 200):
            #print("Request successful")
            #print("Data: {0}".format(r.json()))
            return r.json()
        else:
            print("Request failed (Status-Code: {0})".format(r.status_code))
            exit(2)
    except RequestException:
        print("Request failed with an exception!")
        exit(1)



# 1.8.0 --> Wirkenergie A+ 		    /Wh
# 2.8.0 --> Wirkenergie A- 		    /Wh
# 1.7.0 --> Momentanleistung P+		/W
# 2.7.0 --> Momentanleistung P-		/W
#32.7.0 --> Spannung L1			    /V	    /x10^-1
#52.7.0 --> Spannung L2			    /V	    /x10^-1
#72.7.0 --> Spannung L3			    /V	    /x10^-1
#31.7.0 --> Strom L1			    /A	    /x10^-2
#51.7.0 --> Strom L2			    /A	    /x10^-2
#71.7.0 --> Strom L3			    /A	    /x10^-2
#13.7.0 --> Leistungsfaktor		    /n.A.	/x10^-3

def format_json_data(jsonData = '{}'):
    
    formattedJSON1 = {}
    formattedJSON = {}
    
    for i in jsonFields:
        if i == '32.7.0' or i == '52.7.0' or i == '72.7.0':
            formattedJSON1[i] = round(float(jsonData[i]) * 0.1, 5)
        elif i == '31.7.0' or i == '51.7.0' or i == '71.7.0':
            formattedJSON1[i] = round(float(jsonData[i]) * 0.01, 5)
        elif i == '13.7.0':
            formattedJSON1[i] = round(float(jsonData[i]) * 0.001, 5)
        else: 
            formattedJSON1[i] = jsonData[i]
    
    for i in formattedJSON1:
        if i == '1.8.0':
            formattedJSON['Wirkenergie_A+'] = formattedJSON1[i]
        elif i == '2.8.0':
            formattedJSON['Wirkenergie_A-'] = formattedJSON1[i]
        elif i == '1.7.0':
            formattedJSON['Momentanleistung_P+'] = formattedJSON1[i]
        elif i == '2.7.0':
            formattedJSON['Momentanleistung_P-'] = formattedJSON1[i]
        elif i == '32.7.0':
            formattedJSON['Spannung_L1'] = formattedJSON1[i]
        elif i == '52.7.0':
            formattedJSON['Spannung_L2'] = formattedJSON1[i]
        elif i == '72.7.0':
            formattedJSON['Spannung_L3'] = formattedJSON1[i]
        elif i == '31.7.0':
            formattedJSON['Strom_L1'] = formattedJSON1[i]        
        elif i == '51.7.0':
            formattedJSON['Strom_L2'] = formattedJSON1[i]        
        elif i == '71.7.0':
            formattedJSON['Strom_L3'] = formattedJSON1[i]        
        elif i == '13.7.0':
            formattedJSON['Leistungsfaktor'] = formattedJSON1[i]
        else:
            formattedJSON[i] = formattedJSON1[i]
    
    return formattedJSON
    

def write_to_influx_dummy(data):

        point = Point("Stromzähler")
        for field in data:
            if field != 'timestamp':
                point = point.field(field, data[field])
            else: 
                point = point.time(datetime.strptime(data[field], TIME_FORMAT), WritePrecision.NS)

        print(point)

def write_to_influx(data):

    with InfluxDBClient(url=INFLUX_URL, token=INFLUX_TOKEN, org=INFLUX_ORG) as client:
        write_api = client.write_api(write_options=SYNCHRONOUS)
        
        for field in data:
            point = Point("Stromzähler")

            if field == 'timestamp':
                point = point.time(datetime.strptime(data[field], TIME_FORMAT), WritePrecision.NS)
            elif field == 'uptime':
                point = point.field(field, data[field])
            else: 
                point = point.field(field, float(data[field]))
            
            write_api.write(INFLUX_BUCKET, INFLUX_ORG, point)
        client.close()


def main():
    print("Starting the collection of Data")
    while True:
        jsonData = get_data_from_api(DATA_SOURCE)
        data = format_json_data(jsonData)
        write_to_influx(data)
        time.sleep(TIMEOUT)


if __name__ == '__main__':
	main()
