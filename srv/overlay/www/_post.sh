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

# Install our basic dependencies.
apt update && apt upgrade -y
apt install -y git python3-pip gunicorn3

# Get our sources.
git clone --branch "master" https://github.com/cyphar/cyphar.com /srv/prod
git clone --branch "dev"    https://github.com/cyphar/cyphar.com /srv/beta
git clone                   https://github.com/cyphar/lgtm       /srv/lgtm

# Install Python dependencies.
pip3 install -r /srv/prod/requirements.txt
pip3 install -r /srv/beta/requirements.txt
# TODO: Build /srv/lgtm/lgtm instead of having to copy it from the host.

# Fix gunicorn3 link -- Debian has a different name for the Python 3 one.
ln -s "$(which gunicorn3)" /usr/local/bin/gunicorn

for service in {prod,beta,lgtm}
do
	getent passwd "www-$service" >/dev/null || \
		useradd -s "/bin/false" -d "/srv/$service" -U "www-$service"
	chown -R "www-$service:www-$service" "/srv/$service" "/srv/$service.env"

	systemctl enable "www-cyphar@$service"
	systemctl start "www-cyphar@$service"
done
