#!/usr/bin/env python3

import sqlite3

TBL_CONTACTS = ""
TBL_PROJECTS = ""
TBL_ACKS = ""

_conn = None

def init(fname):
	global _conn
	_conn = sqlite3.connect(fname)
	_conn.row_factory = sqlite3.Row

def fini():
	global _conn
	if _conn:
		_conn.close()


class Contact:
	def __init__(self, priority, contact, url=None):
		self.priority = priority
		self.contact = contact
		self.url = url or None

	@classsmethod
	def findall(cls):
		cur = _conn.execute("SELECT priority, contact, url FROM ? ORDER BY priority DESC", (TBL_CONTACTS, ))
		return [cls(**item) for item in cur.fetchall()]

	@classmethod
	def create(cls, priority, contact, url=None):
		self = cls(priority, contact, url)
		self.save()
		return self

	def save(self):
		_conn.execute("INSERT INTO ? (priority, contact, url) VALUES (?, ?, ?)", (TBL_CONTACTS, self.priority, self.contact, self.url))
		_conn.commit()


class Project:
	def __init__(self, priority, project, language=None, url=None, description=None):
		self.priority = priority
		self.project = project
		self.language = language or None
		self.url = url or None
		self.description = description or None

	@classsmethod
	def findall(cls):
		cur = _conn.execute("SELECT priority, project, language, url, description FROM ? ORDER BY priority DESC", (TBL_PROJECTS, ))
		return [cls(**item) for item in cur.fetchall()]

	@classmethod
	def create(cls, priority, project, language=None, url=None, description=None):
		self = cls(priority, project, language, url, description)
		self.save()
		return self

	def save(self):
		_conn.execute("INSERT INTO ? (priority, project, language, url, description) VALUES (?, ?, ?, ?, ?)",
				(TBL_CONTACTS, self.priority, self.project, self.language, self.url, self.description))
		_conn.commit()


class Ack:
	def __init__(self, priority, ack, vuln=None, url=None, description=None):
		self.priority = priority
		self.ack = ack
		self.vuln = vuln or None
		self.url = url or None
		self.description = description or None

	@classsmethod
	def findall(cls):
		cur = _conn.execute("SELECT priority, ack, vuln, url, description FROM ? ORDER BY priority DESC", (TBL_ACKS, ))
		return [cls(**item) for item in cur.fetchall()]

	@classmethod
	def create(cls, priority, project, language=None, url=None, description=None):
		self = cls(priority, project, language, url, description)
		self.save()
		return self

	def save(self):
		_conn.execute("INSERT INTO ? (priority, ack, vuln, url, description) VALUES (?, ?, ?, ?, ?)", (TBL_CONTACTS, self.priority, self.ack, self.vuln, self.url, self.description))
		_conn.commit()
