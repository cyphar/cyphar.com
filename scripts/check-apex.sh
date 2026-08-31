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

# Sanity-check the cyphar.com "apex" project state.
#
# Usage: scripts/check-apex.sh
set -Eeuo pipefail

root="$(dirname "$0")/.."

fail() {
	echo "check-apex: $*" >&2
	exit 1
}

# Every non-blank line must be a comment or a well-formed
# "/source destination [code]" rule -- anything else is silently dropped by
# the host's parser.
check_format() {
	bad="$(grep -Ev '^(#|$|/[^[:space:]]*[[:space:]]+[^[:space:]]+([[:space:]]+[0-9]{3})?$)' "$1" || true)"
	[ -z "$bad" ] || fail "malformed line(s) in $1: $bad"
}

check_format "$root/apex/_redirects"

# Redirects beat assets, so every file checked into apex/.well-known/ must have
# a self-rewrite (200) masking rule above the /.well-known/* splat, or it can
# never be served.
(cd "$root/apex" && find .well-known -type f) | while read -r f; do
	grep -qxF "/$f  /$f  200" "$root/apex/_redirects" || \
		fail "apex/_redirects is missing the self-rewrite rule '/$f  /$f  200'"
done

# The matrix well-known files exist twice (apex/ for Cloudflare, srv/ for the
# box's dot.cyphar.com fallback) -- keep them in sync.
for f in client server; do
	cmp -s "$root/apex/.well-known/matrix/$f" \
		"$root/srv/overlay/_host/srv/wkd/.well-known/matrix/$f" || \
		fail "apex/.well-known/matrix/$f is out of sync with the srv/ copy"
done

echo "check-apex: OK"
