-- Insert current data into database
-- Run clean.sql and schema.sql *before* this

--------------
-- CONTACTS --
--------------

INSERT INTO tbl_contacts (priority, contact, url) VALUES (30, "GitHub", "https://github.com/cyphar");
INSERT INTO tbl_contacts (priority, contact, url) VALUES (20, "Bitbucket", "https://bitbucket.org/cyphar");
INSERT INTO tbl_contacts (priority, contact, url) VALUES (10, "Twitter", "https://twitter.com/thecyphar");
INSERT INTO tbl_contacts (priority, contact, url) VALUES (-10, "LinkedIn", "https://www.linkedin.com/profile/view?id=327408242");

--------------
-- PROJECTS --
--------------

INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (120, "dotRush", "Java", "https://play.google.com/store/apps/details?id=com.jtdev.dotrush", "Very addictive android game. Eat the smaller dots to grow and eat bigger dots. Just don't get dotrush'd.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (110, "ninjabot", "Python", "https://github.com/ackwell/ninjabot", "Modular IRC bot written in Python. Supports dynamic reloading of bot modules and core.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (100, "rawline", "C", "https://github.com/cyphar/rawline", "The small and self-contained line-editing library. Written in less than 1000 lines of ANSI C and can easily be included in any project.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (90, "magnesium", "Python", "https://github.com/cyphar/magnesium", "<b>(WIP)</b> Explosive messaging -- decentralised, zero-configuration LAN chat system for enterprise.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (80, "perfectgift", "Python + SQL", "https://github.com/cyphar/perfectgift", "A tornado webapp, written by Group 4 at the NCSS Summer School 2014 all-nighter. Get the perfect gift for your friends, with this innovative wishlist app.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (70, "epyc", "Python", "https://github.com/cyphar/epyc", "A python templating language (written for <a href='https://github.com/cyphar/perfectgift'>perfectgift</a>).");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (60, "synge", "C", "https://github.com/cyphar/synge", "Very powerful scientific calculation engine. Supports variables, short-cutting conditions and recursive expressions.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (50, "copper", "C", "https://github.com/cyphar/copper", "Cu, a C userland.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (40, "ttu", "C", "https://github.com/cyphar/ttu", "Small program which silently converts TCP sockets to Unix sockets for any standard *nix executable.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (30, "tic-tac-toe", "C", "https://github.com/cyphar/tic-tac-toe", "The classic game, boasting a heuristic AI. Supports zero, one or two players.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (20, "ascii-snake", "C", "https://github.com/cyphar/ascii-snake", "Remake of the Nokia snake game for *nix consoles, with several compile-time configuration options.");
INSERT INTO tbl_projects (priority, project, language, url, description) VALUES (10, "moss", "C", "https://github.com/cyphar/moss", "A simple command-line file viewer. Supports regex searching, multiple files, switching to <code>$EDITOR</code> and file reloading.");

-----------
-- KUDOS --
-----------

INSERT INTO tbl_kudos (priority, ack, vuln, url, description) VALUES (10, "Grok Learning", "Sandbox Bypass", "https://groklearning.com/security", "Due to a misconfiguration in the testing machine's firewall, the sandbox could access the internet. This allowed for the disclosure of test data (as well as possible exploitation vectors).");

------------------
-- COMPETITIONS --
------------------

INSERT INTO tbl_competitions (priority, comp, rank, url, description) VALUES (10, "K17 CTF - 2013", "4th Overall", "https://ctf.k17.org/scores", "A competition which contained challenges pertaining to web applications, reverse engineering and exploitation, cryptography, network and memory forensics and unix exploitation. I was mostly involved in the reverse engineering, cryptography and unix exploitation aspects of the competition and assisted the members working on the web application.");
INSERT INTO tbl_competitions (priority, comp, rank, url, description) VALUES (0, "PHDays CTF IV Quals - 2014", NULL, "http://quals.phdays.ru/", "This competition contained a grab-bag of many different aspects of information security, the most interesting of which was a MMORPG for the contestants (where hacking the game was rewarded with CTF points). I was mostly involved in the escaping of sandboxes and information gathering aspects of the competition. I also assisted team members working on the cryptography challenges.");
