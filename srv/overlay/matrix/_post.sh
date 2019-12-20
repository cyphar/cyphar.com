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
groupadd -g 5000 synapse
useradd -u 5000 -g synapse -s/bin/false -d/ synapse

# Create logdir.
mkdir -p /var/log/matrix-synapse
chmod 0750 /var/log/matrix-synapse
chown synapse:synapse /var/log/matrix-synapse

# Install synapse from experimental.
zypper addrepo -f obs://network:messaging:matrix obs-matrix
zypper --gpg-auto-import-keys refresh
zypper install -y matrix-synapse python3-systemd

systemctl enable matrix-synapse
systemctl start matrix-synapse
