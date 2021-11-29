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

zypper in -y wget tar libicu

# Create jellyfin user.
getent group jellyfin >/dev/null || groupadd -g 5000 jellyfin
getent passwd jellyfin >/dev/null || useradd -u 5000 -g jellyfin -s/bin/false -d/ jellyfin

# Fetch latest ffmpeg.
/srv/update_ffmpeg.sh

# Fetch the latest version.
/srv/update_jellyfin.sh

systemctl enable jellyfin
systemctl start jellyfin
