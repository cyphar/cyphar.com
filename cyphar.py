#!/usr/bin/env python3

import os
import argparse
import flask

app = flask.Flask(__name__)
app.config.from_object(__name__)

@app.route("/home")
@app.route("/")
def home():
	return flask.render_template("home.html")

@app.route("/projects")
@app.route("/code")
def projects():
	return flask.render_template("projects.html")

@app.route("/security")
def security():
	return flask.render_template("security.html")

@app.route("/favicon.ico")
def _favicon():
	return flask.send_from_directory(os.path.join(app.root_path, "static"), "favicon.ico")

def run_server(host, port):
	app.debug = True
	app.run(host=host, port=port)

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Start a flask server, running the 'cyphar.com' website.")
	parser.add_argument("-p", "--port", type=int, default=8888)
	parser.add_argument("-H", "--host", type=str, default="0.0.0.0")
	args = parser.parse_args()

	run_server(args.host, args.port)
