#!/usr/bin/env python3

import sqlite3

def getpath(fname):
	dirname = os.path.dirname(__file__)
	return os.path.join(dirname, fname)

def init(fname):
	with open(fname, "w"):
		pass

	with sqlite3.connect(fname) as conn:
		sql = ""

		with open(getpath("clean.sql")) as f:
			sql += f.read()

		with open(getpath("schema.sql")) as f:
			sql += f.read()

		conn.executescript(sql)
		conn.commit()
