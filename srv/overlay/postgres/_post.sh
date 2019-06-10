#!/bin/bash
# Copyright (C) 2014-2019 Aleksa Sarai <cyphar@cyphar.com>
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

# Get the bits required to get JSON output out of pg_lsclusters.
apt install -y libjson-perl jq

# Figure out the version and cluster name.
version="$(pg_lsclusters -j | jq -r '.[].version')"
cluster="$(pg_lsclusters -j | jq -r '.[].cluster')"
pgdata="$(pg_lsclusters -j | jq -r '.[].pgdata')"

# If the data directory is not already present in /srv/ (meaning that we
# already have it set up to use the host data), we destroy destroy that
# cluster, and re-create it with our new configs.
if ! [[ "$pgdata" =~ /srv/* ]]
then
	systemctl stop "postgresql@$version-$cluster"
	pg_dropcluster "$version" "$cluster"
	pg_createcluster "$version" "$cluster"
fi

systemctl start "postgresql@$version-$cluster"
systemctl enable "postgresql@$version-$cluster"
