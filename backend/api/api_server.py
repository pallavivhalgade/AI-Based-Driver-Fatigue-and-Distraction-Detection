from flask import Flask, jsonify
from flask_cors import CORS
import json
from pathlib import Path

app = Flask(__name__)
CORS(app)

STATUS_FILE = Path("status.json")


@app.route("/")
def home():
    return jsonify({"message": "AI Driver Monitor API is running"})


@app.route("/status")
def status():
    if STATUS_FILE.exists():
        with STATUS_FILE.open("r") as file:
            return jsonify(json.load(file))

    return jsonify({
        "driver_status": "Normal",
        "eyes": "Open",
        "yawning": "No",
        "head_pose": "Forward",
        "alert_count": 0,
        "mode": "Online"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
