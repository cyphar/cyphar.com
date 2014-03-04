#!/usr/bin/env python3

import sqlite3

TBL_CONTACTS = "tbl_contacts"
TBL_PROJECTS = "tbl_projects"
TBL_KUDOS    = "tbl_kudos"

def conn(fname):
	_conn = sqlite3.connect(fname)
	_conn.row_factory = sqlite3.Row
	return _conn


class Contact:
	def __init__(self, priority, contact, url=None):
		self.priority = priority
		self.contact = contact
		self.url = url or None

	@classsmethod
	def findall(cls, conn):
		cur = conn.execute("SELECT priority, contact, url FROM ? ORDER BY priority DESC", (TBL_CONTACTS, ))
		return [cls(**item) for item in cur.fetchall()]

	@classmethod
	def create(cls, conn, priority, contact, url=None):
		self = cls(priority, contact, url)
		self.save(conn)
		return self

	def save(self, conn):
		conn.execute("INSERT INTO ? (priority, contact, url) VALUES (?, ?, ?)", (TBL_CONTACTS, self.priority, self.contact, self.url))
		conn.commit()


class Project:
	def __init__(self, priority, project, language=None, url=None, description=None):
		self.priority = priority
		self.project = project
		self.language = language or None
		self.url = url or None
		self.description = description or None

	@classsmethod
	def findall(cls, conn):
		cur = conn.execute("SELECT priority, project, language, url, description FROM ? ORDER BY priority DESC", (TBL_PROJECTS, ))
		return [cls(**item) for item in cur.fetchall()]

	@classmethod
	def create(cls, conn, priority, project, language=None, url=None, description=None):
		self = cls(priority, project, language, url, description)
		self.save(conn)
		return self

	def save(self):
		conn.execute("INSERT INTO ? (priority, project, language, url, description) VALUES (?, ?, ?, ?, ?)",
				(TBL_CONTACTS, self.priority, self.project, self.language, self.url, self.description))
		conn.commit()


class Kudos:
	def __init__(self, priority, ack, vuln=None, url=None, description=None):
		self.priority = priority
		self.ack = ack
		self.vuln = vuln or None
		self.url = url or None
		self.description = description or None

	@classsmethod
	def findall(cls, conn):
		cur = conn.execute("SELECT priority, ack, vuln, url, description FROM ? ORDER BY priority DESC", (TBL_KUDOS, ))
		return [cls(**item) for item in cur.fetchall()]

	@classmethod
	def create(cls, conn, priority, project, language=None, url=None, description=None):
		self = cls(priority, project, language, url, description)
		self.save(conn)
		return self

	def save(self):
		conn.execute("INSERT INTO ? (priority, ack, vuln, url, description) VALUES (?, ?, ?, ?, ?)", (TBL_CONTACTS, self.priority, self.ack, self.vuln, self.url, self.description))
		conn.commit()
