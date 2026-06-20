## cyphar.com ##

The code for [my personal website](https://www.cyphar.com/), as well as the
scripts and configurations used to host the internal services within the
`cyphar.com` realm (you can find those in `srv/`).

The website is a static site built with [Hugo](https://gohugo.io/).

### Layout ###

```
hugo.toml         site configuration
content/          page content
  _index.md         home page
  code.md           /code, /security, /papers (rendered from data/)
  security.md
  papers.md
  blog/             blog posts (one Markdown file per post)
data/             structured data for the code/security/papers pages
static/           files served at the site root (robots.txt, _redirects, ...)
themes/cyphar/    the custom theme (layouts + CSS/JS/fonts/images)
srv/              host/service configuration (unrelated to the website build)
```

### Building ###

```
hugo serve     # local preview at http://localhost:1313/
hugo           # build into public/
```

### License ###

This project is licensed under the GNU Affero General Public License.

```
Copyright (C) 2014-2025 Aleksa Sarai <cyphar@cyphar.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```

The blog posts are released under the
[Creative Commons BY-SA 4.0 license](https://creativecommons.org/licenses/by-sa/4.0/).
