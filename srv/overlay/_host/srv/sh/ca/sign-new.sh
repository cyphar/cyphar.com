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

# TODO: Switch to getopt.
SUBJECT="$1"
SANS="${2:-DNS:$SUBJECT}"
KEY="${3:-rsa:2048}"

INAME="${INAME:-i1}"

pushd "$INAME/"
openssl req \
	-subj "/C=AU/ST=NSW/O=dot.cyphar.com/CN=$SUBJECT/emailAddress=webmaster@cyphar.com" \
	-addext "subjectAltName=$SANS" \
	-new -newkey "$KEY" -keyout "private/$SUBJECT.key" -out "certreqs/$SUBJECT.req"

openssl ca -config ./openssl.conf \
	-rand_serial -days 398 -extensions server_cert -infiles "certreqs/$SUBJECT.req"
popd

echo "New key was stored in $INAME/private/$SUBJECT.key."
echo "New certificate can be found in $INAME/newcertsdb."
ls "$INAME/newcertsdb"
