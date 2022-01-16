#!/usr/bin/env python3
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

import os
import math
import argparse
import urllib.parse

import flask
import flask_flatpages
from feedwerk import atom

import db.data
from pkg import flatpages_permacode
from pkg import flatpages_markmeta

FLATPAGES_AUTORELOAD = True
FLATPAGES_ROOT = "doc/published"
FLATPAGES_EXTENSION = ".md"
FLATPAGES_MARKDOWN_EXTENSIONS = [
	"fenced_code",
	"mdx_subscript", "mdx_superscript",
	"markdown.extensions.toc", "markdown.extensions.smarty",
]

PAGE_SIZE = 10
ATOM_FEED_SIZE = 15

app = flask.Flask(__name__)
app.config.from_object(__name__)
# Generate flatpages.
flatpages = flask_flatpages.FlatPages(app)
flatpages_markmeta.init_flatpages(flatpages)
# Construct flatpages permacode redirects.
permacode = flatpages_permacode.Permacode(app, flatpages)

@app.before_request
def set_locale():
	flask.g.date_format = "%d %B %Y"

@app.route("/home")
@app.route("/")
def home():
	return flask.render_template("home.html", contacts=db.data.CONTACTS)

@app.route("/code")
def code():
	flatpages_markmeta.markthemdown(db.data.CONTRIBS, "description")
	flatpages_markmeta.markthemdown(db.data.PROJECTS, "description")
	flatpages_markmeta.markthemdown(db.data.PROGCOMPS, "description")

	return flask.render_template("code.html", projects=db.data.PROJECTS, contribs=db.data.CONTRIBS, comps=db.data.PROGCOMPS)

@app.route("/security")
def security():
	flatpages_markmeta.markthemdown(db.data.KUDOS, "description")
	flatpages_markmeta.markthemdown(db.data.SECCOMPS, "description")

	return flask.render_template("security.html", kudos=db.data.KUDOS, comps=db.data.SECCOMPS)

@app.route("/papers")
def papers():
	flatpages_markmeta.markthemdown(db.data.PAPERS.authored, "description")
	flatpages_markmeta.markthemdown(db.data.PAPERS.coauthored, "description")

	return flask.render_template("papers.html", papers=db.data.PAPERS)

@app.route("/talks")
def talks():
	return flask.redirect("/src/talks", code=302)

@app.route("/paperback")
def paperback():
	return flask.redirect("/src/paperback", code=302)

@app.route("/src/")
@app.route("/src/<project>")
@app.route("/src/<project>/<path:rest>")
def src_redirect(project=None, rest=None):
	redir = db.data.REDIRECTS.src.get(project)
	if not redir:
		flask.abort(404)
	if rest is not None:
		redir += "/" + rest
	return flask.redirect(redir, code=302)

@app.route("/bin/")
@app.route("/bin/<project>")
def bin_redirect(project=None):
	redir = db.data.REDIRECTS.bin.get(project)
	if not redir:
		flask.abort(404)
	return flask.redirect(redir, code=302)

def _get_posts(_filter=None):
	# Generate set of posts in the FLATPAGES_ROOT.
	posts = sorted(flatpages, key=lambda item: item["published"], reverse=True)
	# Filter the set of posts by the given filter (if applicable).
	if _filter:
		posts = [post for post in posts if _filter(post)]
	return posts

def _paginate_posts(posts, page=1):
	# Get number of pages from post list.
	pages = int(math.ceil(len(posts) / PAGE_SIZE))
	# Slice to page.
	page_start = (page - 1) * PAGE_SIZE
	page_end = page * PAGE_SIZE
	return posts[page_start:page_end], pages

def bl_filter_function(bl_filter_type, bl_filter):
	if bl_filter is not None:
		# bl_filter is case-insensitive.
		bl_filter = bl_filter.lower()
	return {
		"tag": lambda post: bl_filter in {tag.lower() for tag in post["tags"]},
		"author": lambda post: bl_filter == post["author"].lower(),
		None: lambda post: True,
	}.get(bl_filter_type, None)

@app.route("/blog/")
@app.route("/blog/<int:page>")
@app.route("/blog/<bl_filter_type>/<bl_filter>/")
@app.route("/blog/<bl_filter_type>/<bl_filter>/<int:page>")
def blog(bl_filter_type=None, bl_filter=None, page=1):
	_filter = bl_filter_function(bl_filter_type, bl_filter)
	if _filter is None:
		flask.abort(404)

	# Get posts.
	posts = _get_posts(_filter)
	pg_posts, pages = _paginate_posts(posts, page)

	# If the page number is invalid, bail.
	# Allow for a page number of 1 if there are no posts -- for the "no posts found" error.
	if page < 1 or (page > pages and posts):
		flask.abort(404)

	# Used to abstract filter links.
	flask.g.bl_url_for = lambda **kwargs: flask.url_for("blog", bl_filter_type=bl_filter_type, bl_filter=bl_filter, **kwargs)
	flask.g.bl_filter_type = bl_filter_type
	flask.g.bl_filter = bl_filter
	return flask.render_template("blog/list.html", posts=pg_posts, page=page, pages=pages)

@app.route("/blog/posts.atom")
@app.route("/blog/<bl_filter_type>/<bl_filter>/posts.atom")
def blog_feed(bl_filter_type=None, bl_filter=None):
	def make_external(url):
		return urllib.parse.urljoin(flask.request.url_root, url)

	# Build the filter.
	_filter = bl_filter_function(bl_filter_type, bl_filter)
	if _filter is None:
		flask.abort(404)

	# Create Atom feed.
	feed = atom.AtomFeed(title="Cyphar's Blog",
	                     title_type="text",
	                     author="Aleksa Sarai",
	                     rights="Copyright (C) 2014-2020 Aleksa Sarai. Licensed under CC-BY-SA 4.0.",
	                     rights_type="text",
	                     subtitle="The wild ramblings of Aleksa Sarai.",
	                     subtitle_type="text",
	                     feed_url=flask.request.url,
	                     url=make_external(flask.url_for("blog", bl_filter_type=bl_filter_type, bl_filter=bl_filter)))

	# Get latest posts.
	posts = _get_posts(_filter)[:ATOM_FEED_SIZE]
	for post in posts:
		feed.add(title=post.meta["title"],
		         title_type="text",
		         author=post.meta["author"],
		         url=make_external(flask.url_for("blog_post", name=post.path)),
		         summary=post.meta["description"],
		         summary_type="html",
		         updated=post.meta["updated"],
		         published=post.meta["published"],
		         categories=[{"term": tag} for tag in post.meta["tags"]])
	return feed.get_response()

@app.route("/blog/post/<name>")
def blog_post(name):
	# Get the permacode version of the name. If there is one, redirect to the
	# permacode version. This is necessary to support old-style names (that
	# didn't include a date).
	perma = permacode.fetch(name)
	if perma != name:
		return flask.redirect(flask.url_for("blog_post", name=perma), code=302)
	# Get requested post.
	post = flatpages.get_or_404(name)
	return flask.render_template("blog/post.html", post=post)

@app.route("/favicon.ico")
def _favicon():
	static = os.path.join(app.root_path, "static", "img")
	return flask.send_from_directory(static, "favicon.ico")

@app.route("/<filename>.txt")
def _txt_redirect(filename):
	static = os.path.join(app.root_path, "static", "txt")
	return flask.send_from_directory(static, "%s.txt" % (filename,))

@app.errorhandler(401)
def authentication_required(_):
	return flask.render_template('401.html'), 401

@app.errorhandler(403)
def forbidden(_):
	return flask.render_template('403.html'), 403

@app.errorhandler(404)
def page_not_found(_):
	return flask.render_template('404.html'), 404

@app.errorhandler(410)
def gone(_):
	return flask.render_template('410.html'), 410

@app.errorhandler(500)
def internal_server_error(_):
	return flask.render_template('500.html'), 500

def run_server(host, port, debug):
	app.debug = debug
	app.run(host=host, port=port)

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description="Start a flask server, running the 'cyphar.com' website.")
	parser.add_argument("-p", "--port", type=int, default=8888)
	parser.add_argument("-H", "--host", type=str, default="0.0.0.0")
	parser.add_argument("-D", "--debug", action="store_const", const=True, default=False)

	args = parser.parse_args()
	run_server(args.host, args.port, args.debug)
