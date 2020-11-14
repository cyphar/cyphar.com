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

function setup_opensuse() {
	# Update repos.
	zypper removerepo openSUSE-Tumbleweed-Non-Oss || :
	zypper update -y

	# Install sudo.
	zypper install -y sudo

	# Switch to paranoid mode to disable all setuid bits.
	sed -i 's|^PERMISSION_SECURITY=.*|PERMISSION_SECURITY="paranoid"|g' /etc/sysconfig/security
	chkstat --system
}

function setup_debian() {
	# Update repos.
	apt update
	apt upgrade -y

	# Install sudo.
	apt install -y sudo

	# Don't allow any non-root users to use it.
	chmod '-s,o-rwx' "$(which sudo)"
}

# Figure out the distribution.
source /etc/os-release
case "$ID" in
	"opensuse"*)
		setup_opensuse
		;;
	"debian")
		setup_debian
		;;
esac
