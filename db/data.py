#!/usr/bin/env python3
# cyphar.com: my personal site's flask app
# Copyright (C) 2014, 2015, 2016 Aleksa Sarai

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
		"name": "mkonion",
		"language": "Go",
		"url": "/src/mkonion",
		"description": "Small, simple and self-contained tool to create a Tor onion address for an existing container without restarts or modification of the container. I use this to manage the [onion link for this website](http://dqzsjhefvopcfbn5.onion/)."
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
		"name": "epyc",
		"language": "Python",
		"url": "/src/epyc",
		"description": "A Python templating language like Jinja (written for [perfectgift](/src/perfectgift))."
	},
	{
		"name": "synge",
		"language": "C",
		"url": "/src/synge",
		"description": "Very powerful scientific calculation engine. Supports variables, short-cutting conditions and recursive expressions."
	},
	{
		"name": "pulltab",
		"language": "C",
		"url": "/src/pulltab",
		"description": "A complete rewrite of [corkscrew](http://agroman.net/corkscrew/), allowing you to tunnel arbitrary stream connections through HTTP proxies."
	},
	{
		"name": "ttu",
		"language": "C",
		"url": "/src/ttu",
		"description": "Small program which silently converts TCP sockets to Unix sockets for any standard *nix executable."
	},
	{
		"name": "sched",
		"language": "C",
		"url": "/src/sched",
		"description": "A simple toy scheduler for the Arduino, which currently doesn't support preemptive scheduling.",
	},
	{
		"name": "dotRush",
		"language": "Java",
		"url": "/src/dotrush",
		"description": "Very addictive android game. Eat the smaller dots to grow and eat bigger dots. Just don't get dotrush'd."
	},
	{
		"name": "keplerk2-halo",
		"language": "Python + Shell",
		"url": "/src/keplerk2-halo",
		"description": "All of the scripts written and used during my research project into Asteroseismology at the Univeristy of Sydney, as well as some document and reports on my findings using these scripts.",
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
		"description": "The free software application container engine, to which I have contributed several fairly significant patch sets (ranging from security fixes to feature implementations)."
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
			"Portus": "/src/portus",
		}),
		"language": "Ruby",
		"description": "Authorization service and frontend for the Docker registry, which supports self-hosting and has many of the features of the Docker Hub.",
	},
	{
		"links": ordered_dict({
			"Team Win Recovery Project": "/src/twrp",
		}),
		"language": "C++",
		"description": "A free software custom recovery for Android-based devices, the only such recovery which supports disk encryption. I implemented CyanogenMod-style NxN pattern decryption for TWR NxN pattern decryption for TWRP.",
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
		None:            "https://github.com/cyphar",
		"cypharcom":     "https://github.com/cyphar/cyphar.com",
		"docker":        "https://github.com/docker/docker",
		"libcontainer":  "https://github.com/docker/libcontainer",
		"runc":			 "https://github.com/opencontainers/runc",
		"linux":         "https://www.kernel.org/",
		"dotrush":       "https://play.google.com/store/apps/details?id=com.jtdev.dotrush",
		"redone":        "https://github.com/cyphar/redone",
		"ninjabot":      "https://github.com/ackwell/ninjabot",
		"rawline":       "https://github.com/cyphar/rawline",
		"perfectgift":   "https://github.com/cyphar/perfectgift",
		"epyc":          "https://github.com/cyphar/epyc",
		"synge":         "https://github.com/cyphar/synge",
		"copper":        "https://github.com/cyphar/copper",
		"ttu":           "https://github.com/cyphar/ttu",
		"docker-rebase": "https://github.com/cyphar/docker-rebase",
		"mkonion":       "https://github.com/cyphar/mkonion",
		"twrp":          "https://twrp.me/",
		"portus":        "https://github.com/SUSE/Portus",
		"pulltab":       "https://github.com/cyphar/pulltab",
		"sched":         "https://github.com/cyphar/sched",
		"keplerk2-halo": "https://github.com/cyphar/keplerk2-halo",
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
