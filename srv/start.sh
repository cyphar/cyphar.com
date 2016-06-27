#!/bin/zsh
# cyphar.com: my personal site's flask app
# Copyright (C) 2014, 2015, 2016 Aleksa Sarai

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Start-up script for cyphar.com backend services.

# Wrapper for `docker run`, which deletes containers that failed to start.
# NOTE: We cannot use `docker run --rm`, because `--rm` is incompatible with
#       `-d` (even though that should be how it works).
function _dockrun() {
	# Save the image name, for later pretty-printing.
	__name="${@[-1]}"

	# Start container and get container id.
	echo "[+] Starting '${__name}'."
	__container_id=$(docker run $@ 2>/dev/null)

	# Couldn't start the container? Remove any left-over traces.
	# NOTE: Disable this if debugging a failing server start. This is used in
	#       production to ensure that no disk-space is wasted by unused containers.
	if [[ $? != 0 ]]; then
		echo "[!] Failed to start '${__name}'."
		echo "[-] Purging container ${__container_id}."
		docker stop "${__container_id}" 2>&1 >/dev/null
		docker rm -f "${__container_id}" 2>&1 >/dev/null
	else
		echo "[*] Successfully started '${__name}'."
	fi
}

# NOTE: Obviously replace the port numbers here with the ones you wish to use.
#       Make sure they match up with the `proxy_pass` directives in your nginx
#       setup.

# See: github.com/cyphar/cyphar.com
_dockrun -d -p 127.0.0.1:8001:5000 cyphar/personal-site:latest
