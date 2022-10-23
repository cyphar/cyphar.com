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

echo "CRLs not supported with this registry setup!" >&2
exit 1

OUTDIR="${1:-/srv/static/ca}"

for dir in */
do
	dir="${dir%/}"
	pushd "$dir"
	openssl ca -config ./openssl.conf \
		-gencrl -out "crl/${dir}ca-crl.pem"
	cp "crl/${dir}ca-crl.pem" "$OUTDIR/${dir}ca-dot.cyphar.com.crl"
	popd
done
