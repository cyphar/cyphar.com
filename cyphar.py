#!/usr/bin/env python3

# cyphar.com: my personal site's flask app
# Copyright (c) 2014 Cyphar

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# 1. The above copyright notice and this permission notice shall be included in
#    all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import argparse
import flask
import db.api

app = flask.Flask(__name__)
app.config.from_object(__name__)
dbfile = "cyphar.db"

@app.before_request
def getdb():
	conn = getattr(flask.g, "conn", None)

	if not conn:
		flask.g.conn = db.api.getdb(dbfile)

@app.teardown_appcontext
def cleardb(exception):
	conn = getattr(flask.g, "conn", None)

	if conn:
		conn.close()

	flask.g.conn = None

@app.route("/home")
@app.route("/")
def home():
	contacts = db.api.Contact.findall(flask.g.conn)
	return flask.render_template("home.html", contacts=contacts)

@app.route("/projects")
@app.route("/code")
def projects():
	project_list = db.api.Project.findall(flask.g.conn)
	return flask.render_template("projects.html", projects=project_list)

@app.route("/security")
def security():
	kudos = db.api.Kudos.findall(flask.g.conn)
	comps = db.api.Competition.findall(flask.g.conn)
	return flask.render_template("security.html", kudos=kudos, comps=comps)

@app.route("/src/")
@app.route("/src/<project>")
def src(project=None):
	redir = db.api.SrcRedirect.find(flask.g.conn, project)

	if not redir:
		flask.abort(404)

	return flask.redirect(redir.url, code=302)

@app.route("/bin/")
@app.route("/bin/<project>")
def bin(project=None):
	redir = db.api.BinRedirect.find(flask.g.conn, project)

	if not redir:
		flask.abort(404)

	return flask.redirect(redir.url, code=302)

@app.route("/favicon.ico")
def _favicon():
	static = os.path.join(app.root_path, "static")
	return flask.send_from_directory(static, "favicon.ico")

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
