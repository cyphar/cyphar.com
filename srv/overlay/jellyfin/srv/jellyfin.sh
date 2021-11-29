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

# This is based on <https://jellyfin.org/docs/general/administration/installing.html#linux-generic-amd64>.

set -Eeuxo pipefail

JELLYFINDIR="/opt/jellyfin"

"$JELLYFINDIR/bin/jellyfin" \
	-d "$JELLYFINDIR/data" \
	-C "$JELLYFINDIR/cache" \
	-c "$JELLYFINDIR/config" \
	-l "$JELLYFINDIR/log" \
	--ffmpeg /opt/ffmpeg/ffmpeg
