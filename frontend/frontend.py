#############################################################################
# Frontend Microservice: user entry point; makes requests to Binary/Decimal
# and Celsius/Fahrenheit Microservices to convert the input value and 
# also makes requests to Datastore Microservice to get the user's operations
# history
#############################################################################

from flask import Flask, render_template, jsonify, request, session
import requests
import sys
import logging
from waitress import serve
import uuid

app = Flask(__name__)
app.secret_key = 'super secret key'

@app.route("/")
def menu():
    try:
      # set up sessions variables
      if not session.get('uid'):
        # only create user id if not already created
        session['uid'] = uuid.uuid4()
      session['celsius_input'] = celsius_input = "0"
      session['celsius_output'] = celsius_output = ""
      session['fahrenheit_input'] = fahrenheit_input = "0"
      session['fahrenheit_output'] = fahrenheit_output = ""
      session['decimal_input'] = decimal_input = "0"
      session['decimal_output'] = decimal_output = ""
      session['binary_input'] = binary_input = "0"
      session['binary_output'] = binary_output = ""
      return render_template("index.html", celsius_input = celsius_input, celsius_output = celsius_output,\
                              fahrenheit_input = fahrenheit_input, fahrenheit_output = fahrenheit_output,\
                              decimal_input = decimal_input, decimal_output = decimal_output,\
                              binary_input = binary_input, binary_output = binary_output, uid = session["uid"])
    except Exception as e:
        return str(e)

@app.route("/celsius2fahrenheit", methods=['POST'])
def celsius2fahrenheit():
  try:
    celsius_input = request.form["celsius"]
    response = requests.post('http://microservice-temp:8002/celsius2fahrenheit', data={'celsius': celsius_input, 'id': session["uid"]})
    if response.status_code == 200:
        fahrenheit_output = str(response.json().get("fahrenheit"))
        # Update session variables
        session["celsius_input"] = celsius_input
        session["fahrenheit_output"] = fahrenheit_output
        return render_template("index.html", celsius_input = celsius_input, celsius_output = session["celsius_output"],\
                                fahrenheit_input = session["fahrenheit_input"], fahrenheit_output = fahrenheit_output,\
                                decimal_input = session["decimal_input"], decimal_output = session["decimal_output"],\
                                binary_input = session["binary_input"], binary_output = session["binary_output"], uid = session["uid"])
    else:
        return response.text
    
  except Exception as e:
    return str(e)

@app.route("/fahrenheit2celsius", methods=['POST'])
def fahrenheit2celsius():
  try:
    fahrenheit_input = request.form["fahrenheit"]
    response = requests.post('http://microservice-temp:8002/fahrenheit2celsius', data={'fahrenheit': fahrenheit_input, 'id': session["uid"]})
    if response.status_code == 200:
        celsius_output = str(response.json().get("celsius"))
        # Update session variables
        session["celsius_output"] = celsius_output
        session["fahrenheit_input"] = fahrenheit_input
        return render_template("index.html", celsius_input = session["celsius_input"], celsius_output = celsius_output,\
                                fahrenheit_input = fahrenheit_input, fahrenheit_output = session["fahrenheit_output"],\
                                decimal_input = session["decimal_input"], decimal_output = session["decimal_output"],\
                                binary_input = session["binary_input"], binary_output = session["binary_output"], uid = session["uid"])
    else:
        return response.text
    
  except Exception as e:
    return str(e)

@app.route("/binary2decimal", methods=['POST'])
def binary2decimal():
  try:
    binary_input = request.form["binary"]
    response = requests.post('http://microservice-bin-dec:8001/binary2decimal', data={'binary': binary_input, 'id': session["uid"]})
    if response.status_code == 200:
        decimal_output = str(response.json().get("decimal"))
        # Update session variables
        session["decimal_output"] = decimal_output
        session["binary_input"] = binary_input
        return render_template("index.html", celsius_input = session["celsius_input"], celsius_output = session["celsius_output"],\
                                fahrenheit_input = session["fahrenheit_input"], fahrenheit_output = session["fahrenheit_output"],\
                                decimal_input = session["decimal_input"], decimal_output = decimal_output,\
                                binary_input = binary_input, binary_output = session["binary_output"], uid = session["uid"])
    else:
        return response.text
    
  except Exception as e:
    return str(e)

@app.route("/decimal2binary", methods=['POST'])
def decimal2binary():
  try:
    decimal_input = request.form["decimal"]
    response = requests.post('http://microservice-bin-dec:8001/decimal2binary', data={'decimal': decimal_input, 'id': session["uid"]})
    if response.status_code == 200:
        binary_output = response.json().get("binary")
        # Update session variables
        session["decimal_input"] = decimal_input
        session["binary_output"] = binary_output
        return render_template("index.html", celsius_input = session["celsius_input"], celsius_output = session["celsius_output"],\
                                fahrenheit_input = session["fahrenheit_input"], fahrenheit_output = session["fahrenheit_output"],\
                                decimal_input = decimal_input, decimal_output = session["decimal_output"],\
                                binary_input = session["binary_input"], binary_output = binary_output, uid = session["uid"])
    else:
        return response.text
    
  except Exception as e:
    return str(e)

@app.route("/view_history", methods=['GET'])
def viewHistory():
  try:
    uid = request.args.get("uid")
    response = requests.post('http://microservice-datastore:8003/read', data={'id': session["uid"]})
    if response.status_code == 200:
        data_dict = response.json()
        data_dict = {int(k):v for k,v in data_dict.items()}
        return render_template("history.html", data_dict=dict(sorted(data_dict.items())))
    else:
      return response.text
    
  except Exception as e:
    return str(e)


if __name__ == "__main__":
    logger = logging.getLogger('waitress')
    logger.setLevel(logging.DEBUG)
    serve(app, host="0.0.0.0", port=sys.argv[1])