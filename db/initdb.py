#!/usr/bin/env python3

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
