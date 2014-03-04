#!/usr/bin/env python3

import sqlite3

TBL_CONTACTS = "tbl_contacts"
TBL_PROJECTS = "tbl_projects"
TBL_KUDOS = "tbl_kudos"

def getdb(fname):
	"Obtain a connection to the database."

	_conn = sqlite3.connect(fname)
	_conn.row_factory = sqlite3.Row

	return _conn

class Contact(object):
	"Contact information on a service."

	def __init__(self, cid, priority, contact, url=None):
		self.cid = cid
		self.priority = priority
		self.contact = contact
		self.url = url or None

	@classmethod
	def findall(cls, conn):
		"Find all contacts in database."

		cur = conn.execute("SELECT cid, priority, contact, url FROM %s ORDER BY priority DESC" % TBL_CONTACTS)
		return [cls(item["cid"], item["priority"], item["contact"], item["url"]) for item in cur.fetchall()]

	@classmethod
	def create(cls, conn, priority, contact, url=None):
		"Create a new contact and store it in the database."

		conn.execute("INSERT INTO %s (priority, contact, url) VALUES (?, ?, ?)" % TBL_CONTACTS, (priority, contact, url))
		conn.commit()

		cid = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
		return cls(cid, priority, contact, url)

	def save(self, conn):
		"Save (update) the contact to the database."

		conn.execute("UPDATE %s SET priority=?, contact=?, url=? WHERE cid=?" % TBL_CONTACTS, (self.priority, self.contact, self.url, self.cid))
		conn.commit()


class Project(object):
	"Project information."

	def __init__(self, pid, priority, project, language=None, url=None, description=None):
		self.pid = pid
		self.priority = priority
		self.project = project
		self.language = language or None
		self.url = url or None
		self.description = description or None

	@classmethod
	def findall(cls, conn):
		"Find all projects in database."

		cur = conn.execute("SELECT pid, priority, project, language AS lang, url, description AS desc FROM %s ORDER BY priority DESC" % TBL_PROJECTS)
		return [cls(item["pid"], item["priority"], item["project"], item["lang"], item["url"], item["desc"]) for item in cur.fetchall()]

	@classmethod
	def create(cls, conn, priority, project, language=None, url=None, description=None):
		"Create a new project and store it in the database."

		conn.execute("INSERT INTO %s (priority, project, language, url, description) VALUES (?, ?, ?, ?, ?)" % TBL_CONTACTS, (priority, project, language, url, description))
		conn.commit()

		pid = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
		return cls(pid, priority, project, language, url, description)

	def save(self, conn):
		"Save (update) the project to the database."

		conn.execute("UPDATE %s SET priority=?, project=?, language=?, url=?, description=? WHERE pid=?" % TBL_CONTACTS,
				(self.priority, self.project, self.language, self.url, self.description, self.pid))
		conn.commit()


class Kudos(object):
	"Acknowledgements for security work (aka Kudos)."

	def __init__(self, kid, priority, ack, vuln=None, url=None, description=None):
		self.kid = kid
		self.priority = priority
		self.ack = ack
		self.vuln = vuln or None
		self.url = url or None
		self.description = description or None

	@classmethod
	def findall(cls, conn):
		"Find all acknowledgements in the database."

		cur = conn.execute("SELECT kid, priority, ack, vuln, url, description AS desc FROM %s ORDER BY priority DESC" % TBL_KUDOS)
		return [cls(item["kid"], item["priority"], item["ack"], item["vuln"], item["url"], item["desc"]) for item in cur.fetchall()]

	@classmethod
	def create(cls, conn, priority, ack, vuln=None, url=None, description=None):
		"Create a new acknowledgement and store it in the database."

		conn.execute("INSERT INTO %s (priority, ack, vuln, url, description) VALUES (?, ?, ?, ?, ?)" % TBL_CONTACTS, (priority, ack, vuln, url, description))
		conn.commit()

		kid = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
		return cls(kid, priority, ack, vuln, url, description)

	def save(self, conn):
		"Save (update) the acknowledgement to the database."

		conn.execute("UPDATE %s SET priority=?, ack=?, vuln=?, url=?, description=? WHERE kid=?" % TBL_CONTACTS, (self.priority, self.ack, self.vuln, self.url, self.description, self.kid))
		conn.commit()
