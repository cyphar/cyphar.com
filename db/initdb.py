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
import sqlite3

DBFILE = "cyphar.db"

def getpath(fname):
	"Get path relative to module."

	dirname = os.path.dirname(__file__)
	return os.path.join(dirname, fname)

def initdb(fname):
	"Clean out and generate a new 'cyphar.com' database schema."

	with open(fname, "w"):
		pass

	with sqlite3.connect(fname) as conn:
		sql = ""

		with open(getpath("clean.sql")) as f:
			sql += f.read()

		with open(getpath("schema.sql")) as f:
			sql += f.read()

		with open(getpath("data.sql")) as f:
			sql += f.read()

		conn.executescript(sql)
		conn.commit()

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Generate the 'cyphar.com' sqlite database.")
	parser.add_argument("-d", "--db-file", dest="dbfile", help="path to database file to be created", type=str, default=DBFILE)
	args = parser.parse_args()

	initdb(args.dbfile)
