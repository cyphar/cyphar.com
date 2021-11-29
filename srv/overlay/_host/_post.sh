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

services=(
	"nginx.service"
    "certbot-renew.timer"
    "glacier-backup-sync.timer"
    "glacier-backup.timer"
    "nextcloud-cron.timer"
    "zfs-scrub@lxd.timer"
    "zfs-scrub@tank.timer"
)

systemctl daemon-reload

# Disable and re-enable all the services to ensure the symlinks aren't stale.
systemctl disable "${services[@]}"
systemctl enable "${services[@]}"
# And start them. They're mostly timers so this just sets the clock ticking.
systemctl restart "${services[@]}"
# Reload apparmor.d/ profiles.
systemctl reload apparmor

getent group  tor >/dev/null || groupadd -g 1000000 tor
getent passwd tor >/dev/null || useradd -u 1000000 -g tor -s/bin/false -d/ tor

getent group  postgres >/dev/null || groupadd -g 1000001 postgres
getent passwd postgres >/dev/null || useradd -u 1000001 -g postgres -s/bin/false -d/ postgres

getent group  nextcloud >/dev/null || groupadd -g 1000002 nextcloud
getent passwd nextcloud >/dev/null || useradd -u 1000002 -g nextcloud -s/bin/false -d/ nextcloud

getent group  coturn >/dev/null || groupadd -g 1000003 coturn
getent passwd coturn >/dev/null || useradd -u 1000003 -g coturn -s/bin/false -d/ coturn

getent group  matrix >/dev/null || groupadd -g 1000004 matrix
getent passwd matrix >/dev/null || useradd -u 1000004 -g matrix -s/bin/false -d/ matrix

getent group  rtorrent >/dev/null || groupadd -g 1000005 rtorrent
getent passwd rtorrent >/dev/null || useradd -u 1000005 -g rtorrent -s/bin/false -d/ rtorrent

getent group  jellyfin >/dev/null || groupadd -g 1000006 jellyfin
getent passwd jellyfin >/dev/null || useradd -u 1000006 -g jellyfin -s/bin/false -d/ jellyfin
