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

# Figure out the distribution.
source /etc/os-release
# We only work on openSUSE.
[[ "$ID" =~ opensuse* ]] || exit 1

# Set up host-mapped service user.
groupadd -g 5000 rtorrent
useradd -u 5000 -g rtorrent -s/bin/false -m -d/home/rtorrent rtorrent

# Symlink the rtorrent config.
ln -s /store/rtorrent.rc /home/rtorrent/.rtorrent.rc

# Install rtorrent.
zypper install -y rtorrent screen

# Start the service.
systemctl enable rtorrent
systemctl start rtorrent
