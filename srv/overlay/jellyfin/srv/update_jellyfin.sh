#!/bin/bash
# Copyright (C) 2014-2020 Aleksa Sarai <cyphar@cyphar.com>
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

mkdir -p /opt/jellyfin/{data,config,cache,log}

JELLYFIN_VERSION="${1:-10.9.4}"
BACKUP="${BACKUP:-}"

systemctl stop jellyfin
if [ -n "$BACKUP" ]
then
	pushd /opt
	tar cvfJ "jellyfin-backup-$(date --iso-8601).tar.xz" jellyfin
	popd
fi

pushd /opt/jellyfin

# Fetch requested jellyfin binaries.
rm -f jellyfin_*.tar.gz*
wget "https://repo.jellyfin.org/files/server/linux/latest-stable/amd64/jellyfin_${JELLYFIN_VERSION}-amd64.tar.xz"
# TODO: Figure out a nice way of getting the hash to verify we downloaded it properly...
#wget "https://repo.jellyfin.org/releases/server/linux/stable/combined/jellyfin_${JELLYFIN_VERSION}_amd64.tar.gz.sha256sum"
#sha256sum -c "jellyfin_${JELLYFIN_VERSION}_amd64.tar.gz.sha256sum"

# Extract and update the "bin" symlink.
subdir="jellyfin_${JELLYFIN_VERSION}"
mkdir -p "$subdir"
tar xvf "jellyfin_${JELLYFIN_VERSION}-amd64.tar.xz" -C "$subdir" --strip-components 1
ln -sfT "$subdir" bin

# Clean up
rm -f "jellyfin_${JELLYFIN_VERSION}.tar.gz*"

popd

chown -R jellyfin:jellyfin "/opt/jellyfin/jellyfin_${JELLYFIN_VERSION}"
chown jellyfin:jellyfin /opt/jellyfin

systemctl restart jellyfin
