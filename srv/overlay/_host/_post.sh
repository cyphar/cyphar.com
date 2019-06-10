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
