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

for dir in */
do
	dir="${dir%/}"
	pushd "$dir"
	for cert in newcertsdb/*
	do
		subject_cn="$(openssl x509 -in "$cert" -noout -subject -nameopt multiline | sed -nE '/\s*commonName\s*=/s/[^=]*=\s*//p')"
		subject_hash="$(openssl x509 -in "$cert" -noout -subject_hash)"
		serial="$(openssl x509 -in "$cert" -noout -serial | sed -E 's/^serial=//')"
		mv -nv "$cert" "certsdb/$subject_cn-$serial-$subject_hash.crt"
	done
	popd
done
