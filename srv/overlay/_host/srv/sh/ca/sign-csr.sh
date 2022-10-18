#!/bin/bash
# Copyright (C) 2022 Aleksa Sarai <cyphar@cyphar.com>
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

set -Eeuxo pipefail

function bail() {
	echo "[!]" "$@" >&2
	exit 1
}

CSR_NAME="$1"
SAN="${2:-}"

INAME="${INAME:-i1}"

[[ -n "$CSR_NAME" && -f "$INAME/certreqs/$CSR_NAME" ]] || bail "No CSR found with name $CSR_NAME."

pushd "$INAME/"
if [[ -z "$SAN" ]]
then
	extensions=( "-extensions" "server_cert" )
else
	ext_file="$(mktemp --tmpdir "${INAME}ca-dot.cyphar.com.tmpconfig.XXXXXX")"
	# shellcheck disable=SC2064
	trap "rm -f '$ext_file'" EXIT

	# Copy the "server_cert" section from openssl.conf.
	awk <openssl.conf '
		/^\[/ {
			current_section=gensub(/\[[[:space:]]*([^[:space:]]*)[[:space:]]*\]/, "\\1", "g", $0);
			# Rewrite the section name.
			if (current_section == "server_cert") {
				print "[ server_cert_forced_san ]";
				next;
			}
		}
		# Output all lines in the section we want.
		current_section == "server_cert" { print }' >>"$ext_file"
	# Add the forced SAN field.
	echo "subjectAltName = $SAN" >>"$ext_file"

	# Output for our own sanity.
	cat "$ext_file"
	extensions=( "-extfile" "$ext_file" "-extensions" "server_cert_forced_san" )
fi

openssl ca -config ./openssl.conf \
	-rand_serial -days 398 "${extensions[@]}" -infiles "certreqs/$CSR_NAME"
popd

echo "New certificate can be found in $INAME/newcertsdb."
ls "$INAME/newcertsdb"
