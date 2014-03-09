#!/usr/bin/env python3

import os
import argparse
import flask
import db.api

app = flask.Flask(__name__)
app.config.from_object(__name__)
dbfile = "cyphar.db"

def getdb():
	conn = getattr(flask.g, "conn", None)

	if not conn:
		conn = flask.g.conn = db.api.getdb(dbfile)

	return conn

@app.teardown_appcontext
def cleardb(exception):
	conn = getattr(flask.g, "conn", None)

	if conn:
		conn.close()

	flask.g.conn = None

@app.route("/home")
@app.route("/")
def home():
	conn = getdb()

	flask.g.contacts = db.api.Contact.findall(conn)
	return flask.render_template("home.html")

@app.route("/projects")
@app.route("/code")
def projects():
	conn = getdb()

	flask.g.projects = db.api.Project.findall(conn)
	return flask.render_template("projects.html")

@app.route("/security")
def security():
	conn = getdb()

	flask.g.kudos = db.api.Kudos.findall(conn)
	flask.g.comps = db.api.Competition.findall(conn)
	return flask.render_template("security.html")

@app.route("/favicon.ico")
def _favicon():
	return flask.send_from_directory(os.path.join(app.root_path, "static"), "favicon.ico")

@app.errorhandler(401)
def authentication_required(error):
	return flask.render_template('401.html'), 401

@app.errorhandler(403)
def forbidden(error):
	return flask.render_template('403.html'), 403

@app.errorhandler(404)
def page_not_found(exception):
	return flask.render_template('404.html'), 404

@app.errorhandler(410)
def gone(exception):
	return flask.render_template('410.html'), 410

@app.errorhandler(500)
def internal_server_error(error):
	return flask.render_template('500.html'), 500

def run_server(host, port, debug):
	app.debug = debug
	app.run(host=host, port=port)

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Start a flask server, running the 'cyphar.com' website.")
	parser.add_argument("-p", "--port", type=int, default=8888)
	parser.add_argument("-H", "--host", type=str, default="0.0.0.0")
	parser.add_argument("-D", "--debug", action="store_const", const=True, default=False)
	parser.add_argument("-d", "--db-file", dest="dbfile", type=str, default=dbfile)

	args = parser.parse_args()

	dbfile = args.dbfile
	run_server(args.host, args.port, args.debug)
