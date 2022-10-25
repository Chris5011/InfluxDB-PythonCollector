import json
import random
from datetime import datetime
from flask import Flask, jsonify

app = Flask(__name__)
@app.route('/metrics', methods=['GET'])
def index():

	now = datetime.now()
	t = now.strftime("%Y:%m:%dT%H:%M:%S")

	jsonData = {
		"timestamp":"{0}".format(t),
		"1.8.0":"{0}".format(str(random.randint(100000,250000))),
		"2.8.0":"{0}".format(str(random.randint(20000,35000))),
		"1.7.0":"{0}".format(str(random.randint(100,1000))),
		"2.7.0":"{0}".format(str(random.randint(100,1000))),
        "32.7.0":"{0}".format(str(random.randint(1000,5500))),
		"52.7.0":"{0}".format(str(random.randint(1000,5500))),
		"72.7.0":"{0}".format(str(random.randint(1000,5500))),
		"31.7.0":"{0}".format(str(random.randint(10,250))),
		"51.7.0":"{0}".format(str(random.randint(100,750))),
		"71.7.0":"{0}".format(str(random.randint(100,750))),
		"13.7.0":"{0}".format(str(random.randint(100,750))),
		"uptime":"0000:21:57:17"
		}
	return jsonData

app.run()


#   	"1.8.0":"10912315",
#		"2.8.0":"1851416",
#		"1.7.0":"560",
#		"2.7.0":"450",
#		"32.7.0":"2347",
#		"52.7.0":"2353",
#		"72.7.0":"2356",
#		"31.7.0":"86",
#		"51.7.0":"263",
#		"71.7.0":"133",
#		"13.7.0":"321",
#		"uptime":"0000:21:57:17"
