#!/bin/zsh

# cyphar.com: my personal site's flask app
# Copyright (C) 2014, 2015 Cyphar

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# 1. The above copyright notice and this permission notice shall be included in
#    all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

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
