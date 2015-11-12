#!/usr/bin/env python3
# cyphar.com: my personal site's flask app
# Copyright (C) 2014, 2015 Cyphar

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# 1. The above copyright notice and this permission notice shall be included in
#    all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# data.py -- website data store in in-memory objects.

import collections

class MagicDict(dict):
	"A dict-like object that allows you to reference keys through attributes using magic."
	def __init__(self, *args, **kwargs):
		super().__init__(*args, **kwargs)
		self.__dict__ = self

# Quick and dirty way to automatically make a consistent OrderedDict statically.
ordered_dict = lambda *args, **kwargs: collections.OrderedDict(sorted(dict(*args, **kwargs).items()))

# Contacts.

CONTACTS = [
	{
		"contact": "GitHub",
		"url": "https://github.com/cyphar",
	},
	{
		"contact": "Twitter",
		"url": "https://twitter.com/lordcyphar",
	},
	{
		"contact": "Keybase",
		"url": "https://keybase.io/cyphar",
	},
	{
		"contact": "Reddit",
		"url": "https://www.reddit.com/user/cyphar",
	},
	{
		"contact": "Bitbucket",
		"url": "https://bitbucket.org/cyphar",
	},
	{
		"contact": "LinkedIn",
		"url": "https://www.linkedin.com/in/cyphar",
	},
]
CONTACTS = [MagicDict(item) for item in CONTACTS]

# Code.

PROJECTS = [
	{
		"name": "dotRush",
		"language": "Java",
		"url": "/src/dotrush",
		"description": "Very addictive android game. Eat the smaller dots to grow and eat bigger dots. Just don't get dotrush'd."
	},
	{
		"name": "redone",
		"language": "Python",
		"url": "/src/redone",
		"description": "A 'correct' implementation of regular expression matching and substitution using finite state automata."
	},
	{
		"name": "rawline",
		"language": "C",
		"url": "/src/rawline",
		"description": "The small and self-contained line-editing library. Written in less than 1000 lines of ANSI C and can easily be included in any project."
	},
	{
		"name": "perfectgift",
		"language": "Python + SQL",
		"url": "/src/perfectgift",
		"description": "A tornado webapp, written by Group 4 at the NCSS Summer School 2014 all-nighter. Get the perfect gift for your friends, with this innovative wishlist app."
	},
	{
		"name": "epyc",
		"language": "Python",
		"url": "/src/epyc",
		"description": "A python templating language (written for [perfectgift](/src/perfectgift))."
	},
	{
		"name": "synge",
		"language": "C",
		"url": "/src/synge",
		"description": "Very powerful scientific calculation engine. Supports variables, short-cutting conditions and recursive expressions."
	},
	{
		"name": "copper",
		"language": "C",
		"url": "/src/copper",
		"description": "Cu, a C userland."
	},
	{
		"name": "ttu",
		"language": "C",
		"url": "/src/ttu",
		"description": "Small program which silently converts TCP sockets to Unix sockets for any standard *nix executable."
	},
	{
		"name": "tic-tac-toe",
		"language": "C",
		"url": "/src/tic-tac-toe",
		"description": "The classic game, boasting a heuristic AI. Supports zero, one or two players."
	},
	{
		"name": "ascii-snake",
		"language": "C",
		"url": "/src/ascii-snake",
		"description": "Remake of the Nokia snake game for *nix consoles, with several compile-time configuration options."
	},
	{
		"name": "moss",
		"language": "C",
		"url": "/src/moss",
		"description": "A simple command-line file viewer. Supports regex searching, multiple files, switching to `$EDITOR` and file reloading."
	},
]
PROJECTS = [MagicDict(item) for item in PROJECTS]

CONTRIBS = [
	{
		"links": ordered_dict({
			"Linux": "/src/linux",
		}),
		"language": "C + ASM",
		"description": 'A modern (and exceptionally widely used) Unix-like operating system kernel. I implemented the PIDs cgroup controller, which required modification of the `fork(2)` and `clone(2)` paths. In addition, I wrote a [blog post](/blog/post/getting-into-linux-kernel-development) with some recommendations for getting into kernel development.'
	},
	{
		"links": ordered_dict({
			"Docker": "/src/docker",
		}),
		"language": "Go",
		"description": "The open-source application container engine, to which I have contributed several fairly significant patch sets (ranging from security fixes to feature implementations)."
	},
	{
		"links": ordered_dict({
			"runC": "/src/runc",
			"libcontainer": "/src/libcontainer",
		}),
		"language": "Go",
		"description": "A reference implementation for Docker containers. I have contributed several fairly significant patch sets (ranging from security fixes to feature implementations), and maintain parts of the project."
	},
	{
		"links": ordered_dict({
			"ninjabot": "/src/ninjabot",
		}),
		"language": "Python",
		"description": "Modular IRC bot written in Python. Supports dynamic reloading of bot modules and core."
	},
]
CONTRIBS = [MagicDict(item) for item in CONTRIBS]

PROGCOMPS = [
	{
		"name": "NCSS Challenge (Advanced)",
		"rank": "Perfect Score",
		"url": "https://groklearning.com/challenge/",
		"description": "A High School Python programming competition, exploring advanced concepts. I achieved a perfect score in 2013 and 2014."
	},
]

# Security.

KUDOS = [
	{
		"name": "Optus Voicemail Exploit",
		"vuln": "Information Disclosure",
		"url": "https://shubh.am/how-i-bypassed-2-factor-authentication-on-google-yahoo-linkedin-and-many-others/",
		"description": "I assisted Shubham Shah in discovering (and testing) the Optus voicemail PIN bypass exploit. Due to a broken trust model, a forged caller ID would allow an attacker to bypass the PIN protection of voicemail and have full access to the victim's voicemail control panel. I also created the [web application](/bin/voicemail) used to test if a user's phone number is vulnerable."
	},
	{
		"name": "Microsoft (Online Services)",
		"vuln": "Coldfusion Exploit (Root Access)",
		"url": "http://technet.microsoft.com/en-us/security/cc308575#0214",
		"description": "Due to an outdated version of Coldfusion installed on a Microsoft MSN server, I was able to bypass the administrative login and gain administrative access. This would allow me to schedule tasks to run as a privileged user, such as reverse shells, create users, etc."
	},
	{
		"name": "Grok Learning",
		"vuln": "Sandbox Bypass",
		"url": "https://groklearning.com/security",
		"description": "Due to a misconfiguration in the testing machine's firewall, the sandbox could access the internet. This allowed for the disclosure of test data (as well as possible exploitation vectors)."
	},
	{
		"name": "Medium",
		"vuln": "Information Disclosure",
		"url": "https://medium.com/humans.txt",
		"description": "Due to a vulnerable version of OpenSSL, Medium's servers were vulnerable to the [Heartbleed OpenSSL bug](http://heartbleed.com/), allowing up to 64kb of server memory to be disclosed to a hacker (possibly leaking private keys, users' passwords and POST data, etc)."
	},
	{
		"name": "Altervista",
		"vuln": "Information Disclosure",
		"url": "https://en.altervista.org/credits.php",
		"description": "Due to a vulnerable version of OpenSSL, Altervista's control panel was vulnerable to the [Heartbleed OpenSSL bug](http://heartbleed.com/), allowing up to 64kb of server memory to be disclosed to a hacker (possibly leaking private keys, users' passwords and POST data, etc)."
	},
]
KUDOS = [MagicDict(item) for item in KUDOS]

SECCOMPS = [
	{
		"name": "K17 CTF - 2013",
		"rank": "4th Overall",
		"url": "https://ctf.k17.org/scores",
		"description": "A competition which contained challenges pertaining to web applications, reverse engineering and exploitation, cryptography, network and memory forensics and Unix exploitation. I was mostly involved in the reverse engineering, cryptography and unix exploitation aspects of the competition and assisted the members working on the web application."
	},
	{
		"name": "PHDays CTF IV Quals - 2014",
		"rank": None,
		"url": "http://quals.phdays.ru/",
		"description": "This competition contained a grab-bag of many different aspects of information security, the most interesting of which was a MMORPG for the contestants (where hacking the game was rewarded with CTF points). I was mostly involved in the escaping of sandboxes and information gathering aspects of the competition. I also assisted team members working on the cryptography challenges."
	},
]
SECCOMPS = [MagicDict(item) for item in SECCOMPS]

# Redirects under https://www.cyphar.com/{src,bin}/.

REDIRECTS = MagicDict({
	"src": {
		None:           "https://github.com/cyphar",
		"cypharcom":    "https://github.com/cyphar/cyphar.com",
		"docker":       "https://github.com/docker/docker",
		"libcontainer": "https://github.com/docker/libcontainer",
		"runc":			"https://github.com/opencontainers/runc",
		"linux":        "https://www.kernel.org/",
		"dotrush":      "https://play.google.com/store/apps/details?id=com.jtdev.dotrush",
		"redone":       "https://github.com/cyphar/redone",
		"ninjabot":     "https://github.com/ackwell/ninjabot",
		"rawline":      "https://github.com/cyphar/rawline",
		"perfectgift":  "https://github.com/cyphar/perfectgift",
		"epyc":         "https://github.com/cyphar/epyc",
		"synge":        "https://github.com/cyphar/synge",
		"copper":       "https://github.com/cyphar/copper",
		"ttu":          "https://github.com/cyphar/ttu",
		"tic-tac-toe":  "https://github.com/cyphar/tic-tac-toe",
		"ascii-snake":  "https://github.com/cyphar/ascii-snake",
		"moss":         "https://github.com/cyphar/moss",
	},

	"bin": {
		None:        "https://scripts.cyphar.com/",
		"voicemail": "https://scripts.cyphar.com/voicemail",
	},
})

# Papers.

AUTHORED = [

]

COAUTHORED = [
	{
		"title": "Photometry of very bright stars with Kepler and K2 smear data",
		"year": 2015,
		"field": "Astrophysics",
		"url": "http://arxiv.org/abs/1510.00008",
		"description": "This paper came about due to research I was working on within the asteroseismology group at the University of Sydney. After working on figuring out how to do analysis of targets inside the *Kepler* K2 field, a couple of techniques were being worked on -- the one outlined in this paper being one of them. [Benjamin Pope](http://www-astro.physics.ox.ac.uk/~popeb/) and [Tim White](http://www.astro.physik.uni-goettingen.de/~twhite/) did most of the work refining this technique and applying it, my own research uses a very different technique.",
	},
]

PAPERS = MagicDict({
	"authored": [MagicDict(item) for item in AUTHORED],
	"coauthored": [MagicDict(item) for item in COAUTHORED],
})
