# cyphar.com: my personal site's flask app
# Copyright (C) 2014-2019 Aleksa Sarai
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

FROM opensuse/leap:latest
MAINTAINER "Aleksa Sarai <cyphar@cyphar.com>"

# Make sure the repos and packages are up to date
RUN zypper up --no-confirm && \
    zypper in --no-confirm --no-recommends python3 python3-pip git && \
    zypper clean --all

# Set up server user and directory.
RUN useradd -s /bin/false -d /srv/www -- drone

# Install Python requirements.
COPY requirements.txt /requirements.txt
RUN pip3 --no-cache-dir install -r /requirements.txt

# Set up cyphar.com and port config.
ARG PORT=5000
USER drone
EXPOSE $PORT
WORKDIR /srv/www
ENTRYPOINT ["./server.sh"]
CMD []

# Copy over the cyphar.com app source.
# Do this last to preserve the cache.
COPY . /srv/www
