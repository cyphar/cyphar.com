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

# Set up host-mapped service user.
groupadd -g 5000 matrix-synapse
useradd -u 5000 -g matrix-synapse -s/bin/false -d/ matrix-synapse

# Install synapse from experimental.
echo "deb http://deb.debian.org/debian experimental main" >> /etc/apt/sources.list
apt update && apt upgrade -y
apt -t experimental install -y matrix-synapse
