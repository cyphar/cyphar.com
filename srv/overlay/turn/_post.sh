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

# Set up the turnserver user.
groupadd -g 5000 turnserver
useradd -u 5000 -g turnserver -s/bin/false -d/ turnserver

# Set up log directory.
mkdir -p /var/log/coturn
chown -R turnserver:turnserver /var/log/coturn

# Install synapse from experimental.
apt update && apt upgrade -y
apt install -y coturn

# Enable coturn on-boot.
systemctl enable coturn
