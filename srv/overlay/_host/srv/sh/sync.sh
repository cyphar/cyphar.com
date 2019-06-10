#!/bin/zsh
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

set -Eeugo pipefail

SCRIPT_DIRECTORY="$(readlink -m "${(%):-%N}/..")"
. "$SCRIPT_DIRECTORY/conf.sh"

set -x

ZFS_SNAPNAME="$(date +'rclone:%s')"
ZFS_SNAPDIR="${LOCAL_BACK_DIR}/.zfs/snapshot/${ZFS_SNAPNAME}"

function recover() {
	# Remove the temporary snapshot.
	zfs destroy "${LOCAL_BACK_DATASET}@${ZFS_SNAPNAME}" || :
}
trap recover SIGINT EXIT

# Take a zfs snapshot of our backup dataset.
zfs snapshot "${LOCAL_BACK_DATASET}@${ZFS_SNAPNAME}"

# After some testing it looks like it can take a few moments for the snapshot
# to actually be available in .zfs/snapshot. So we busy-wait, checking whether
# the directory is empty.
while ! (ls -1qA "$ZFS_SNAPDIR" | grep -q .)
do
	sleep 1s
done

# Perform a quick sanity-check.
export RESTIC_REPOSITORY="$ZFS_SNAPDIR"
restic --no-lock check

# We now clone the backup to b2.
rclone --config="$RCLONE_CONFIG" -v \
	sync --one-file-system --b2-hard-delete --fast-list \
	"$ZFS_SNAPDIR" "$B2_REMOTE:$B2_BUCKET/$B2_BUCKET_PATH"
