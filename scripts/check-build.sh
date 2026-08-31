#!/bin/bash
# Copyright (C) 2014-2026 Aleksa Sarai <cyphar@cyphar.com>
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

# Sanity-check the built www.cyphar.com site.
#
# Usage: scripts/check-build.sh [path/to/public/_redirects]
set -Eeuo pipefail

root="$(dirname "$0")/.."
redirects="${1:-$root/public/_redirects}"

fail() {
	echo "check-build: $*" >&2
	exit 1
}

# Every non-blank line must be a comment or a well-formed
# "/source destination [code]" rule -- anything else is silently dropped by
# the host's parser.
check_format() {
	bad="$(grep -Ev '^(#|$|/[^[:space:]]*[[:space:]]+[^[:space:]]+([[:space:]]+[0-9]{3})?$)' "$1" || true)"
	[ -z "$bad" ] || fail "malformed line(s) in $1: $bad"
}

[ -f "$redirects" ] || fail "$redirects not found -- run hugo first"
check_format "$redirects"

# Rule count must match the data files (data/govanity.yaml + the shortcuts in
# data/redirects.yaml + the two static /src rules in index.redirects) --
# this catches rules being swallowed by the template.
#
# Both Netlify and Cloudflare Pages silently ignore malformed _redirects lines
# and templating bugs can cause lines to be commented out, so fail loudly
# during builds.
want=$(($(grep -c '^- import:' "$root/data/govanity.yaml") \
      + $(grep -c '^  - from:' "$root/data/redirects.yaml") + 2))
got="$(grep -c '^/' "$redirects")"
[ "$got" -eq "$want" ] || \
	fail "$redirects has $got rules, expected $want from the data files"

# Every go-vanity module needs its 200-rewrite proxy rule, so that all
# sub-paths of the module serve the go-import meta page.
#
# The meta page itself must survive minification in a form "go get" can parse,
# as it uses an *XML* parser that has stricter requirements than HTML parsers
# (hence keepQuotes in hugo.toml).
pubdir="$(dirname "$redirects")"
sed -n 's/^- import:[[:space:]]*cyphar\.com//p' "$root/data/govanity.yaml" | \
while read -r mod; do
	awk -v mod="$mod" '
		!/^#/ && $1 == mod"/*" && $2 == mod"/" && $3 == "200" { found = 1 }
		END { exit !found }
	' "$redirects" || fail "missing go-vanity proxy rule '$mod/*  $mod/  200'"

	page="$pubdir$mod/index.html"
	[ -f "$page" ] || fail "missing go-vanity meta page $page"
	grep -q 'name="go-import"' "$page" || \
		fail "$page has no (quoted) go-import meta tag"
	! grep -qE '(src|href)=/' "$page" || \
		fail "$page has unquoted attribute values -- go get cannot parse these (is minify keepQuotes still set in hugo.toml?)"
done

# The apex/ project has its own checks but run them here too so www builds
# catch apex breakage.
"$root/scripts/check-apex.sh"

echo "check-build: OK ($got rules in $redirects)"
