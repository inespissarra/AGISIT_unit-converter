#####################################################################
# Datastore Microservice: responsible to write and read data from
# redis service
#####################################################################
from flask import Flask, request, jsonify
import redis
from datetime import datetime
import json
import logging
from waitress import serve
import sys

app = Flask(__name__)

redis_leader_client = redis.StrictRedis(host="redis-leader", port=6379)
redis_follower_client = redis.StrictRedis(host="redis-follower", port=6379)

@app.route("/write", methods=['POST'])
def write_to_redis():
    try:
        # get input values
        id = request.form["id"]
        op = request.form["op"]
        input_value = request.form["input_value"]
        input_unit = request.form["input_unit"]
        output_value = request.form["output_value"]
        output_unit = request.form["output_unit"]

        timestamp = datetime.now()

        # write to redis leader
        record = {"timestamp": str(timestamp),"op": op,"input_value": input_value, "input_unit": input_unit,"output_value": output_value,"output_unit":  output_unit}
        redis_leader_client.lpush(id, json.dumps(record))
        return json.dumps(record)
    except Exception as e:
        return str(e), 500

@app.route("/read", methods=['POST'])
def read_from_redis():
    try:
        id = request.form["id"]

        # make the request to redis follower
        data = redis_follower_client.lrange(id, 0, -1)
        if data is None:
            return ""
        else:
            # create a dictionary with all the data and deserialize it
            response = dict()
            for el in range(0, len(data)):
                response[el] = json.loads(data[el])
            return response
    except Exception as e:
        return str(e), 500

if __name__ == "__main__":
    logger = logging.getLogger('waitress')
    logger.setLevel(logging.DEBUG)
    serve(app, host="0.0.0.0", port=sys.argv[1]) # port = 8003