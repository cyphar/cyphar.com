#!/usr/bin/false
# Copyright (C) 2014-2020 Aleksa Sarai <cyphar@cyphar.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import datetime

import flask

def isodate_lstrip(string, fmt="%Y%m%d-"):
	prefix, suffix = None, string
	try:
		# This should *always* raise an error.
		datetime.datetime.strptime(string, fmt)
	except ValueError as v:
		# Parse the error message. Yeah, I know. I'm sorry.
		if "unconverted data remains" in v.args[0]:
			_, _, suffix = v.args[0].partition('unconverted data remains: ')
			prefix = datetime.datetime.strptime(string[:-len(suffix)], fmt)
	return (prefix, suffix)

class Permacode(object):
	EXTENSION_NAME      = "flatpages_permacode"
	_EXTENSION_SELF     = "self"
	_EXTENSION_SUFFIXES = "suffixes"

	def __init__(self, app=None, flatpages=None):
		self.extension_dict = {}
		if app is not None:
			self.init_app(app, flatpages)

	def init_app(self, app, flatpages=None):
		if self.EXTENSION_NAME not in app.extensions:
			app.extensions[self.EXTENSION_NAME] = self.extension_dict
		if flatpages is None:
			if "flatpages" not in app.extensions:
				raise KeyError("could not find flask_flatpages object to permacode")
			# XXX: We only support un-named flatpages for the moment.
			flatpages = app.extensions["flatpages"][None]

		# Stash away what we were initialised with.
		self.app = app
		self.flatpages = flatpages

		# Construct the extension meta-dicts.
		self.extension_dict[self._EXTENSION_SELF] = self
		self.extension_dict[self._EXTENSION_SUFFIXES] = {}

		# If the name starts with a date then we can add it to the index.
		# Otherwise we don't do anything to it.
		for post in self.flatpages:
			prefix, suffix = isodate_lstrip(post.path)
			# The article is an old-style article and doesn't have an ISO-date
			# prefix (so we can't alias it).
			if suffix == post.path or prefix is None:
				continue
			# The article has more than one ISO-date prefix. This will cause
			# errors, and is a Bad Thing™. So let's make the failure loud.
			sub_prefix, sub_suffix = isodate_lstrip(suffix)
			if sub_suffix != suffix or sub_prefix is not None:
				raise ValueError("found post with double-iso-date name: %s" % (post.path,))
			# If there are shared suffixes, we need to not include them as a
			# redirect (because that will make things quite confusing).
			suffix = suffix.lower()
			if suffix in self.extension_dict[self._EXTENSION_SUFFIXES]:
				raise ValueError("found duplicate suffix-alias: %s" % (suffix,))
			self.extension_dict[self._EXTENSION_SUFFIXES][suffix] = post.path

	def fetch(self, name):
		# We want to handle invalid dates as well as just a suffix (if I ever
		# make a URL like 20190120-20190120-foo, this will break very badly so
		# we disallow that in init_app).
		_, name_suffix = isodate_lstrip(name)
		return self.extension_dict[self._EXTENSION_SUFFIXES].get(name_suffix.lower(), name)
