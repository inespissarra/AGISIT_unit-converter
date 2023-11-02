########################################################################
# Binary/Decimal Microservice: responsible to convert binary <-> decimal
# inputs; makes a request to Datastore Microservice to save the new
# operation in redis service
########################################################################

from flask import Flask, jsonify, request
import sys
import logging
from waitress import serve
import requests

app = Flask(__name__)

@app.route("/binary2decimal", methods=['POST'])
def binary2decimal():
  try:
    id = request.form["id"]
    input = binary = int(request.form["binary"])
    count = 0
    decimal = 0
    while binary > 0:
       dig = binary % 10
       decimal = decimal + dig * (2 ** count)
       count += 1
       binary //= 10
       
    message = {"decimal": decimal}
    response = requests.post('http://microservice-datastore:8003/write', data={'id': id, "op": "binary2decimal", "input_value": input, "input_unit": "b",\
                                                                 "output_value": decimal, "output_unit": "d"})
    return jsonify(message)
  except Exception as e:
     return str(e), 500

@app.route("/decimal2binary", methods=['POST'])
def decimal2binary():
  try:
    id = request.form["id"]
    input = decimal = int(request.form["decimal"])
    result = ""
    while decimal > 0 :
      digit = decimal % 2
      decimal //= 2
      result = str(digit) + result
    if result == "":
      result = "0" 
    message = {"binary": result}
    response = requests.post('http://microservice-datastore:8003/write', data={'id': id, "op": "decimal2binary", "input_value": input, "input_unit": "d",\
                                                                  "output_value": result, "output_unit": "b"})
    return jsonify(message)
  except Exception as e:
     return str(e), 500

if __name__ == "__main__":
  logger = logging.getLogger('waitress')
  logger.setLevel(logging.DEBUG)
  serve(app, host="0.0.0.0", port=sys.argv[1]) #port=8001