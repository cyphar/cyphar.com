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
cd "$SCRIPT_DIRECTORY"

function bail() {
	echo "install.sh:" "$@" >&2
	exit 1
}

function usage_exit() {
	cat >&2 <<-EOF
	usage: install.sh [-t <target=source>] <source>

	If <target> is given (or implied) as "host" then the installation occurs on
	the host. Otherwise the installation occurs in the LXD container with the
	given name.
	EOF
	exit "${1:-0}"
}

install_source=
install_target=
while getopts "t:h" opt
do
	case "$opt" in
		t)
			install_target="$OPTARG"
			;;
		h)
			usage_exit
			;;
		?)
			usage_exit 1
			;;
	esac
done

# Get the remaining arguments.
shift "$(($OPTIND - 1))"
[[ "$#" == 1 ]] || usage_exit 1

# Figure out the source and target.
install_source="$1"
[[ -n "$install_target" ]] || install_target="$install_source"

function lxc_install() {
	local src dst
	for src in "$@"
	do
		dst="${src#*/}"

		lxc file push --create-dirs --recursive "$src" "$install_target/$(dirname $dst)"
		lxc_run find "/$dst" -xdev -exec chown root:root {} + || :
	done
}

function host_install() {
	local src dst
	for src in "$@"
	do
		dst="/${src#*/}"

		# TODO: Switch the find to actually filter by what we copied.
		sudo cp -rP --preserve=mode "$src" "$(dirname $dst)"
		#host_run find "/$dst" -xdev -exec chown root:root {} + || :
	done
}

function lxc_run()  { lxc exec "$install_target" -- "$@" ; }
function host_run() { sudo "$@" ; }

# XXX: This only supports having one @@VAR@@ per-line.
function do_replace_vars() {
	local src="$1" lines=()

	echo "[[ BEGIN REPLACEMENT OF $src/** ]]"

	while read -r line
	do
		lines+=("$line")
	done < <(grep -RH '@@.*@@' "$src")

	for line in "${lines[@]}"
	do
		echo "$line"

		file="$(cut -d: -f1  <<<"$line")"
		line="$(cut -d: -f2- <<<"$line")"
		name="$(grep -o '@@.*@@' <<<"$line")"

		read -r "value?$name: "
		sed -i "0,/$name/ s//$value/" "$file"
	done

	echo "[[  END REPLACEMENT OF $src/**  ]]"
}

function do_install() {
	local src="$1"
	local run install

	do_replace_vars "$src"

	run=lxc_run
	install=lxc_install
	[[ "$install_target" == "host" ]] && install=host_install
	[[ "$install_target" == "host" ]] && run=host_run

	# Pre-install scripts.
	if [ -e "$src/_pre.sh" ]
	then
		"$install" "$src/_pre.sh"
		"$run" "/_pre.sh"
	fi

	# Install configs.
	"$install" "$src"/*

	# Post-install scripts.
	if [ -e "$src/_post.sh" ]
	then
		"$install" "$src/_post.sh"
		"$run" "/_post.sh"
	fi

	# Clean up any install-related scripts.
	"$run" rm -rf "/pre.sh" "/post.sh"
}

set -x

# Special-case the copying to and from the host.
[[ "$install_source" == "host" ]] && install_source="_host"

# Apply the _lxd extra source.
# TODO: Add support for a _parent in each source so we can be more flexible.
extra_sources=()
[[ "$install_target" != "host" ]] && extra_sources+=("_lxd")

for src in "${extra_sources[@]}"
do
	do_install "$src"
done
do_install "$install_source"
