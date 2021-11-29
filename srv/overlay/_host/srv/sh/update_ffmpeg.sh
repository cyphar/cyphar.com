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

# XXX XXX XXX: This script is in two places (jellyfin and _host).

set -Eeuxo pipefail

mkdir -p /opt/ffmpeg
rm -rf /opt/ffmpeg/ffmpeg-git-* ||:

pushd /opt/ffmpeg
# Fetch new ffmepg.
wget "https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz"
wget "https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz.md5"
md5sum -c ffmpeg-git-amd64-static.tar.xz.md5
# Extract and update the ffmpeg binaries in bin.
tar xvfJ ffmpeg-git-amd64-static.tar.xz
mv ffmpeg-git-*-static/ff* .
# Remove everything left over.
rm -rf ffmpeg-git-* ||:
popd
