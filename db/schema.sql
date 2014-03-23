-- Applies the cyphar.com schemas
-- Run clean.sql *before* running this.

CREATE TABLE tbl_contacts (
	cid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	priority INTEGER NOT NULL,
	contact TEXT NOT NULL,
	url TEXT
);

CREATE TABLE tbl_projects (
	pid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	priority INTEGER NOT NULL,
	project TEXT NOT NULL,
	language TEXT,
	url TEXT,
	description TEXT
);

CREATE TABLE tbl_kudos (
	kid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	priority INTEGER NOT NULL,
	ack TEXT NOT NULL,
	vuln TEXT,
	url TEXT,
	description TEXT
);

CREATE TABLE tbl_competitions (
	cid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	priority INTEGER NOT NULL,
	comp TEXT NOT NULL,
	rank TEXT,
	url TEXT,
	description TEXT
);

CREATE TABLE tbl_redirects (
	rid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	priority INTEGER NOT NULL,
	key TEXT UNIQUE,
	url TEXT NOT NULL
);
