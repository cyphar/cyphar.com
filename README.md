## cyphar.com ##

The code for [my personal website](https://www.cyphar.com/), as well as the
scripts and configurations used to host the internal services within the
`cyphar.com` realm (you can find those in `srv/`).

The website is a static site built with [Hugo](https://gohugo.io/) and deployed
on [Cloudflare Pages](https://pages.cloudflare.com/).

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
static/           files served at the site root (robots.txt, _headers, ...)
themes/cyphar/    the custom theme (layouts + CSS/JS/fonts/images)
apex/             buildless Pages project serving apex cyphar.com (see below)
scripts/          deploy-time sanity checks (check-build.sh, check-apex.sh)
srv/              host/service configuration (unrelated to the website build)
```

### Building ###

```
hugo serve     # local preview at http://localhost:1313/
hugo           # build into public/
```

### Deployment ###

The site is deployed as **two Cloudflare Pages projects** from this repository.

Pages keeps build settings in the dashboard rather than in a config file, so
they are documented here:

* `www-cyphar-com` (=> `https://www.cyphar.com/`):
  - Build command: `hugo --gc --minify && ./scripts/check-build.sh`
    - >[!IMPORTANT]
      > Do not use `-b $CF_PAGES_URL` as suggested by Cloudflare's Hugo guide,
      > as we statically reference the `baseURL` in a few places.
  - Build output directory: `public`
  - Variables:
    - `HUGO_VERSION=0.165.0`
    - `HUGO_ENV=production`

* `apex-cyphar-com` (=> `https://cyphar.com/`)
  - Build command: `./scripts/check-apex.sh` (no build output)
  - Build output directory: `apex`

The need for these two separate project stems from the fact that we need to
have some specific `.well-known` handling for `cyphar.com` that a redirect to
`www.cyphar.com` would break, and `_redirects` cannot be used to generate
per-hostname redirects. `apex/.well-known` contains the files served statically
from cloud hosting, the rest of `.well-known` gets served from my home server
at `dot.cyphar.com` (see `srv/`), and everything else gets redirected to
`https://www.cyphar.com/`.

- - -

Several zone-level Cloudflare settings must stay off in order to avoid breaking
the site (these are easy to miss as there is no way to configure them from the
repo or in the per-Pages dashboard):

* **Email Obfuscation, Rocket Loader, Auto Minify, Mirage and Polish.** These
  rewrite HTML and inject scripts at the edge, which the `script-src 'self'`
  CSP in `static/_headers` blocks -- they would silently break pages (or tempt
  you to weaken the CSP).
* **Zone-level HSTS.** HSTS is set in `static/_headers` (so it stays in
  version control); setting it in both places makes Cloudflare join the
  duplicates with a comma into an invalid header value.

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
