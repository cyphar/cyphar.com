#!/bin/zsh
# cyphar.com: my personal site's flask app
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
export RESTIC_REPOSITORY="$_RESTIC_REPOSITORY_LOCAL"

ZFS_SNAPNAME="$(date +'restic:%s')"
ZFS_SNAPDIR="${LOCAL_DIR}/.zfs/snapshot/${ZFS_SNAPNAME}"
ZFS_SNAPMOUNT="${LOCAL_DIR}-snapshot"

function recover() {
	# Remove the temporary snapshot.
	umount -l "$ZFS_SNAPMOUNT" || :
	zfs destroy "${LOCAL_DATASET}@${ZFS_SNAPNAME}" || :

	# Remove any stale locks we might've left. In theory this shouldn't happen
	# but "restic unlock" will only remove locks by non-existent processes so
	# there's no real harm in doing it.
	restic unlock || :
}
trap recover SIGINT EXIT

# We perform a local backup here. There isn't really a strong reason to avoid
# downtime (since we are doing the backup through a ZFS snapshot), but doing
# this offline means that we can avoid doing lots of network traffic needlessly
# during the day (which can be a problem due to awful Australian internet).
set -x

# Remove any stale locks.
restic unlock || :

# Do a postgres snapshot -- we use pg_basebackup to avoid taking down the
# database needlessly. We need to clean the backupdir beforehand because
# pg_basebackup doesn't like clobbering things. /srv/postgres-backup is piped
# through to our backup directory.
lxc exec postgres -- sudo -iu postgres \
	find /srv/postgres-backup -mindepth 1 -delete
lxc exec postgres -- sudo -iu postgres \
	pg_basebackup -D /srv/postgres-backup -F tar -R -X stream -P

# Take a zfs snapshot of our storage dataset. The path will be different for
# each invocation of "restic backup" but that's why we group-by tags (and do a
# bind-mount).
zfs snapshot "${LOCAL_DATASET}@${ZFS_SNAPNAME}"

# After some testing it looks like it can take a few moments for the snapshot
# to actually be available in .zfs/snapshot. So we busy-wait, checking whether
# the directory is empty.
while ! (ls -1qA "$ZFS_SNAPDIR" | grep -q .)
do
	sleep 1s
done

# Bind-mount the snapshot to a fixed location, to make life easier for restic
# as well as whoever wants to extract this backup.
mount --bind "$ZFS_SNAPDIR" "$ZFS_SNAPMOUNT"

# Local backup of our snapshot.
restic backup "$ZFS_SNAPMOUNT" \
	--tag "$RESTIC_TAGS" \
	--one-file-system \
	--exclude-if-present ".restic_donotbackup"

# Verify that the backup is sane, and prune any extra packfiles.
restic check

# Delete and prune un-needed snapshots. While we could group-by path (since we
# bind-mount the snapshot) this would end up being bad if the path ever
# changes (we hit this with the /store/deku snapshots).
#
# We keep at least:
#   ... 3 days of hourly snapshots     [  72 hours ]
#   ... 1 month of daily snapshots     [  31 days  ]
#   ... 3 months of weekly snapshots   [  12 weeks ]
#   ... 5 years of monthly backups     [  60 months]
#   ... effectively all yearly backups [9999 years ]
restic forget \
	--group-by tags \
	--tag "$RESTIC_TAGS" \
	--keep-hourly    72 \
	--keep-daily     31 \
	--keep-weekly    12 \
	--keep-monthly   60 \
	--keep-yearly  9999

# Prune any left over data or extra packfiles. --prune doesn't handle the
# latter, so we do it separately for every backup.
restic prune
