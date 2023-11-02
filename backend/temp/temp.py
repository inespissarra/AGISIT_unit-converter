################################################################################
# Celsius/Fahrenheit Microservice: responsible to convert celsius <-> fahrenheit
# inputs; makes a request to Datastore Microservice to save the new
# operation in redis service
################################################################################

from flask import Flask, jsonify, request
import sys
import logging
from waitress import serve
import requests

app = Flask(__name__)

@app.route("/celsius2fahrenheit", methods=['POST'])
def celsius2fahrenheit():
  try:
    id = request.form["id"]
    celsius = request.form["celsius"]
    fahrenheit = float(celsius) * 9/5 + 32
    fahrenheit = round(fahrenheit, 3) # Round to three decimal places
    message = {"fahrenheit": fahrenheit}
    response = requests.post('http://microservice-datastore:8003/write', data={'id': id, "op": "celsius2fahrenheit", "input_value": celsius, "input_unit": "C",\
                                                                  "output_value": fahrenheit, "output_unit": "F"})
    return jsonify(message)
  except Exception as e:
     return str(e), 500

@app.route("/fahrenheit2celsius", methods=['POST'])
def fahrenheit2celsius():
  try:
    id = request.form["id"]
    fahrenheit = request.form["fahrenheit"]
    celsius = (float(fahrenheit) - 32) * 5/9
    celsius = round(celsius, 3)
    message = {"celsius": celsius}
    response = requests.post('http://microservice-datastore:8003/write', data={'id': id, "op": "fahrenheit2celsius", "input_value": fahrenheit, "input_unit": "F",\
                                                                  "output_value": celsius, "output_unit": "C"})
    return jsonify(message)
  except Exception as e:
     return str(e), 500

if __name__ == "__main__":
    logger = logging.getLogger('waitress')
    logger.setLevel(logging.DEBUG)
    serve(app, host="0.0.0.0", port=sys.argv[1]) #port = 8002