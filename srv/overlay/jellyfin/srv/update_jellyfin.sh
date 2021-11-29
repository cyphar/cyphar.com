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

JELLYFIN_VERSION="${1:-10.7.7}"

systemctl stop jellyfin
cp -R /opt/jellyfin "/opt/jellyfin-backup-$(date --iso-8601)"

pushd /opt/jellyfin
# Fetch requested jellyfin binaries.
rm -f jellyfin_*.tar.gz*
wget "https://repo.jellyfin.org/releases/server/linux/stable/combined/jellyfin_${JELLYFIN_VERSION}_amd64.tar.gz"
wget "https://repo.jellyfin.org/releases/server/linux/stable/combined/jellyfin_${JELLYFIN_VERSION}_amd64.tar.gz.sha256sum"
sha256sum -c "jellyfin_${JELLYFIN_VERSION}_amd64.tar.gz.sha256sum"
# Extract and update the "bin" symlink.
tar xvfz "jellyfin_${JELLYFIN_VERSION}_amd64.tar.gz"
ln -sf "jellyfin_${JELLYFIN_VERSION}" bin
# Clean up
rm -f "jellyfin_${JELLYFIN_VERSION}.tar.gz*"
popd

chown -R jellyfin:jellyfin /opt/jellyfin

systemctl restart jellyfin
