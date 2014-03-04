-- Applies the cyphar.com schemas
-- Run clean.sql *before* running this.

CREATE TABLE IF NOT EXISTS tbl_contacts (
	cid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	priority INTEGER NOT NULL,
	contact TEXT NOT NULL,
	url TEXT
);

CREATE TABLE IF NOT EXISTS tbl_projects (
	pid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	priority INTEGER NOT NULL,
	project TEXT NOT NULL,
	language TEXT,
	url TEXT,
	description TEXT
);

CREATE TABLE IF NOT EXISTS tbl_kudos (
	kid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	priority INTEGER NOT NULL,
	ack TEXT NOT NULL,
	vuln TEXT,
	url TEXT,
	description TEXT
);
