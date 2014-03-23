-- cyphar.com: my personal site's flask app
-- Copyright (c) 2014 Cyphar

-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
-- the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- 1. The above copyright notice and this permission notice shall be included in
--    all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

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
