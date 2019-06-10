#!/usr/bin/false
# Copyright (C) 2014-2019 Aleksa Sarai <cyphar@cyphar.com>
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


import bleach
import datetime

import flask
import flask_flatpages

def markmedown(thing):
	return flask_flatpages.pygmented_markdown(thing)

def markitdown(obj, attr, tags=None):
	obj[attr] = markmedown(obj.get(attr, None) or "")
	if tags is not None:
		obj[attr] = bleach.clean(obj[attr], tags=tags, strip=True)

def markthemdown(objs, attr):
	for obj in objs:
		markitdown(obj, attr)

def init_flatpages(flatpages):
	for post in flatpages:
		if "title" not in post.meta:
			post.meta["title"] = "Untitled"

		if "published" not in post.meta:
			# Default to the Unix Epoch.
			post.meta["published"] = datetime.datetime(1970, 1, 1)

		if "updated" not in post.meta:
			# Default to never updated.
			post.meta["updated"] = post.meta["published"]

		if "tags" not in post.meta:
			post.meta["tags"] = []

		if "description" not in post.meta:
			post.meta["description"] = ""

		if "short_description" not in post.meta:
			post.meta["short_description"] = post.meta["description"]

		if "author" not in post.meta:
			post.meta["author"] = "Unknown"

		post.meta["tags"] = sorted(tag.strip() for tag in post.meta["tags"])

		markitdown(post.meta, "title", tags=["em", "strong"])
		markitdown(post.meta, "description")
		markitdown(post.meta, "short_description", tags=[])
