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

# This requires zsh.
[ "$ZSH_VERSION" ] || exit 255
SCRIPT_DIRECTORY="$(readlink -m "${(%):-%N}/..")"

# Configuration for local backup.
LOCAL_BACK_DIR="/store/glacier-backup"
LOCAL_BACK_DATASET="tank/ROOT/glacier-backup"
_RESTIC_REPOSITORY_LOCAL="$LOCAL_BACK_DIR"
export RCLONE_CONFIG="$SCRIPT_DIRECTORY/.secret/rclone.conf"
export B2_REMOTE=b2cyphar

# Uncomment this line to use local restic backups.
#export RESTIC_REPOSITORY="$_RESTIC_REPOSITORY_LOCAL"

# I am currently using BackBlaze (b2) for backups, though I don't use restic's
# native support for b2 backups, so these options only are useful for recovery.
# If I have changed cloud providers this section will not be useful.

# % cat .secret/B2_CREDS
# B2_BUCKET="NOT_MY_REAL_CREDS"
# B2_BUCKET_PATH="NOT_MY_REAL_CREDS"
# B2_ACCOUNT_ID="NOT_MY_REAL_CREDS"
# B2_ACCOUNT_KEY="NOT_MY_REAL_CREDS"
. "$SCRIPT_DIRECTORY/.secret/B2_CREDS"
_RESTIC_REPOSITORY_REMOTE="b2:$B2_BUCKET:$B2_BUCKET_PATH"

# Uncomment these lines to use restic with b2.
#export B2_ACCOUNT_ID B2_ACCOUNT_KEY
#export RESTIC_REPOSITORY="$_RESTIC_REPOSITORY_REMOTE"

# If you're performing a backup with my recovery instructions, remove this line
# and enter the base64 *decoded* password string interactively (or save it to a
# file and point this to it).
export RESTIC_PASSWORD_FILE="$SCRIPT_DIRECTORY/.secret/RESTIC_PASSPHRASE"

# The directory to use for backups and the tag to apply.
RESTIC_TAGS="glacier"
LOCAL_DIR="/store/glacier"
LOCAL_DATASET="tank/ROOT/glacier"
