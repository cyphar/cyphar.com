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

-- Insert current data into database
-- Run clean.sql and schema.sql *before* this

--------------
-- CONTACTS --
--------------

INSERT INTO tbl_contacts (priority, contact, url) VALUES (30, "GitHub", "https://github.com/cyphar");
INSERT INTO tbl_contacts (priority, contact, url) VALUES (20, "Bitbucket", "https://bitbucket.org/cyphar");
INSERT INTO tbl_contacts (priority, contact, url) VALUES (10, "Twitter", "https://twitter.com/thecyphar");
INSERT INTO tbl_contacts (priority, contact, url) VALUES (-10, "LinkedIn", "https://www.linkedin.com/in/cyphar");

--------------
-- PROJECTS --
--------------

INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (120, "dotRush", "Java", "/src/dotrush", "Very addictive android game. Eat the smaller dots to grow and eat bigger dots. Just don't get dotrush'd.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (110, "ninjabot", "Python", "/src/ninjabot", "Modular IRC bot written in Python. Supports dynamic reloading of bot modules and core.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (100, "rawline", "C", "/src/rawline", "The small and self-contained line-editing library. Written in less than 1000 lines of ANSI C and can easily be included in any project.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (80, "perfectgift", "Python + SQL", "/src/perfectgift", "A tornado webapp, written by Group 4 at the NCSS Summer School 2014 all-nighter. Get the perfect gift for your friends, with this innovative wishlist app.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (70, "epyc", "Python", "/src/epyc", "A python templating language (written for <a href='/src/perfectgift'>perfectgift</a>).");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (60, "synge", "C", "/src/synge", "Very powerful scientific calculation engine. Supports variables, short-cutting conditions and recursive expressions.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (50, "copper", "C", "/src/copper", "Cu, a C userland.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (40, "ttu", "C", "/src/ttu", "Small program which silently converts TCP sockets to Unix sockets for any standard *nix executable.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (30, "tic-tac-toe", "C", "/src/tic-tac-toe", "The classic game, boasting a heuristic AI. Supports zero, one or two players.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (20, "ascii-snake", "C", "/src/ascii-snake", "Remake of the Nokia snake game for *nix consoles, with several compile-time configuration options.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (10, "moss", "C", "/src/moss", "A simple command-line file viewer. Supports regex searching, multiple files, switching to <code>$EDITOR</code> and file reloading.");

-----------
-- KUDOS --
-----------

INSERT INTO tbl_kudos (priority, ack, vuln, url, description) VALUES (20, "Microsoft (Online Services)", "Coldfusion Exploit (Root Access)", "http://technet.microsoft.com/en-us/security/cc308575#0214", "Due to an outdated version of Coldfusion installed on a Microsoft MSN server, I was able to bypass the administrative logon and gain administrative access. This would allow me to schedule tasks to run as a privelliged user, such as reverse shells, create users, etc.");
INSERT INTO tbl_kudos (priority, ack, vuln, url, description) VALUES (10, "Grok Learning", "Sandbox Bypass", "https://groklearning.com/security", "Due to a misconfiguration in the testing machine's firewall, the sandbox could access the internet. This allowed for the disclosure of test data (as well as possible exploitation vectors).");

------------------
-- COMPETITIONS --
------------------

INSERT INTO tbl_competitions (priority, comp, rank, url, description) VALUES (10, "K17 CTF - 2013", "4th Overall", "https://ctf.k17.org/scores", "A competition which contained challenges pertaining to web applications, reverse engineering and exploitation, cryptography, network and memory forensics and unix exploitation. I was mostly involved in the reverse engineering, cryptography and unix exploitation aspects of the competition and assisted the members working on the web application.");
INSERT INTO tbl_competitions (priority, comp, rank, url, description) VALUES (0, "PHDays CTF IV Quals - 2014", NULL, "http://quals.phdays.ru/", "This competition contained a grab-bag of many different aspects of information security, the most interesting of which was a MMORPG for the contestants (where hacking the game was rewarded with CTF points). I was mostly involved in the escaping of sandboxes and information gathering aspects of the competition. I also assisted team members working on the cryptography challenges.");

---------------
-- REDIRECTS --
---------------

INSERT INTO tbl_redirects (priority, key, url) VALUES (100, NULL, "https://github.com/cyphar");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "dotrush", "https://play.google.com/store/apps/details?id=com.jtdev.dotrush");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "ninjabot", "https://github.com/ackwell/ninjabot");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "rawline", "https://github.com/cyphar/rawline");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "perfectgift", "https://github.com/cyphar/perfectgift");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "epyc", "https://github.com/cyphar/epyc");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "synge", "https://github.com/cyphar/synge");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "copper", "https://github.com/cyphar/copper");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "ttu", "https://github.com/cyphar/ttu");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "tic-tac-toe", "https://github.com/cyphar/tic-tac-toe");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "ascii-snake", "https://github.com/cyphar/ascii-snake");
INSERT INTO tbl_redirects (priority, key, url) VALUES (20, "moss", "https://github.com/cyphar/moss");
