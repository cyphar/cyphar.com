#!/usr/bin/env python3

# cyphar.com: my personal site's flask app
# Copyright (c) 2014 Cyphar

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

import os
import math
import datetime
import argparse
import urllib.parse

import flask
import flask_flatpages
from werkzeug.contrib import atom
import db.api

DB_FILE = "cyphar.db"

FLATPAGES_AUTORELOAD = True
FLATPAGES_ROOT = "blog/posts"
FLATPAGES_EXTENSION = ".md"
PAGE_SIZE = 20
ATOM_FEED_SIZE = 15

app = flask.Flask(__name__)
flatpages = flask_flatpages.FlatPages(app)
app.config.from_object(__name__)

@app.before_request
def getdb():
	conn = getattr(flask.g, "conn", None)

	if not conn:
		flask.g.conn = db.api.getdb(DB_FILE)

@app.before_request
def set_locale():
	flask.g.date_format = "%d %B %Y"

@app.teardown_appcontext
def cleardb(_):
	conn = getattr(flask.g, "conn", None)

	if conn:
		conn.close()

	flask.g.conn = None

@app.route("/home")
@app.route("/")
def home():
	contacts = db.api.Contact.findall(flask.g.conn)
	return flask.render_template("home.html", contacts=contacts)

@app.route("/projects")
@app.route("/code")
def projects():
	project_list = db.api.Project.findall(flask.g.conn)
	return flask.render_template("projects.html", projects=project_list)

@app.route("/security")
def security():
	kudos = db.api.Kudos.findall(flask.g.conn)
	comps = db.api.Competition.findall(flask.g.conn)
	return flask.render_template("security.html", kudos=kudos, comps=comps)

@app.route("/src/")
@app.route("/src/<project>")
def src_redirect(project=None):
	redir = db.api.SrcRedirect.find(flask.g.conn, project)

	if not redir:
		flask.abort(404)

	return flask.redirect(redir.url, code=302)

@app.route("/bin/")
@app.route("/bin/<project>")
def bin_redirect(project=None):
	redir = db.api.BinRedirect.find(flask.g.conn, project)

	if not redir:
		flask.abort(404)

	return flask.redirect(redir.url, code=302)

def _get_posts(_filter=None):
	# Function to fix post objects.
	def _nice(post):
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

		if "author" not in post.meta:
			post.meta["author"] = "Unknown"

		post.meta["tags"] = sorted(tag.strip() for tag in post.meta["tags"])
		post.meta["description"] = flask_flatpages.pygmented_markdown(post.meta["description"])
		post.meta["url"] = flask.url_for("blog_post", name=post.path)

		return post

	# Generate set of posts in the FLATPAGES_ROOT.
	posts = [_nice(post) for post in flatpages]
	posts = sorted(posts, key=lambda item: item["published"], reverse=True)

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

@app.route("/blog/")
@app.route("/blog/<int:page>")
def blog(page=1):
	# Get posts.
	posts = _get_posts(None)
	pg_posts, pages = _paginate_posts(posts, page)

	# If the page number is invalid, bail.
	# Allow for a page number of 1 if there are no posts -- for the "no posts found" error.
	if page < 1 or (page > pages and posts):
		flask.abort(404)

	# Used to abstract filter links.
	flask.g.bl_url_for = lambda **kwargs: flask.url_for("blog", **kwargs)
	flask.g.bl_filter_type = None
	flask.g.bl_filter = None

	return flask.render_template("blog/list.html", posts=pg_posts, page=page, pages=pages)

@app.route("/blog/tag/<tag>")
@app.route("/blog/tag/<tag>/<int:page>")
def blog_filter_tag(tag, page=1):
	# Generate filter.
	_filter = lambda post: tag in post["tags"]

	# Get posts.
	posts = _get_posts(_filter)
	pg_posts, pages = _paginate_posts(posts, page)

	# If the page number is invalid, bail.
	# Allow for a page number of 1 if there are no posts -- for the "no posts found" error.
	if page < 1 or (page > pages and posts):
		flask.abort(404)

	# If there are no posts, it's a bogus tag.
	if not posts:
		flask.abort(404)

	# Used to abstract filter links.
	flask.g.bl_url_for = lambda **kwargs: flask.url_for("blog_filter_tag", tag=tag, **kwargs)
	flask.g.bl_filter_type = "Tag"
	flask.g.bl_filter = tag

	return flask.render_template("blog/list.html", posts=pg_posts, page=page, pages=pages)

@app.route("/blog/author/<author>")
@app.route("/blog/author/<author>/<int:page>")
def blog_filter_author(author, page=1):
	# Generate filter.
	_filter = lambda post: author == post["author"]

	# Get posts.
	posts = _get_posts(_filter)
	pg_posts, pages = _paginate_posts(posts, page)

	# If the page number is invalid, bail.
	# Allow for a page number of 1 if there are no posts -- for the "no posts found" error.
	if page < 1 or (page > pages and posts):
		flask.abort(404)

	# If there are no posts, it's a bogus tag.
	if not posts:
		flask.abort(404)

	# Used to abstract filter links.
	flask.g.bl_url_for = lambda **kwargs: flask.url_for("blog_filter_author", author=author, **kwargs)
	flask.g.bl_filter_type = "Author"
	flask.g.bl_filter = author

	return flask.render_template("blog/list.html", posts=pg_posts, page=page, pages=pages)

@app.route("/blog/posts.atom")
def blog_feed():
	def make_external(url):
		return urllib.parse.urljoin(flask.request.url_root, url)

	# Create Atom feed.
	feed = atom.AtomFeed(title="Cyphar's Blog",
	                     title_type="text",
	                     author="Aleksa Sarai",
	                     subtitle="The wild ramblings of Aleksa Sarai.",
	                     subtitle_type="text",
	                     feed_url=flask.request.url,
	                     url=make_external(flask.url_for("blog")))

	# Get latest posts.
	posts = _get_posts(None)[:ATOM_FEED_SIZE]

	# Add posts to feed.
	for post in posts:
		feed.add(title=post.meta["title"],
		         title_type="text",
		         author=post.meta["author"],
		         url=make_external(post.meta["url"]),
		         summary=post.meta["description"],
		         summary_type="html",
		         updated=post.meta["updated"],
		         published=post.meta["published"],
		         categories=[{"term": tag} for tag in post.meta["tags"]])

	# Generate Atom response.
	return feed.get_response()

@app.route("/blog/post/<name>")
def blog_post(name):
	# Get requested post.
	post = flatpages.get_or_404(name)

	# Add post identifier data.
	post.meta["ident"] = name

	return flask.render_template("blog/post.html", post=post)

@app.route("/favicon.ico")
def _favicon():
	static = os.path.join(app.root_path, "static")
	return flask.send_from_directory(static, "favicon.ico")

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
	parser.add_argument("-d", "--db-file", dest="dbfile", type=str, default=DB_FILE)

	args = parser.parse_args()

	DB_FILE = args.dbfile
	run_server(args.host, args.port, args.debug)
