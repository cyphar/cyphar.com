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

FROM alpine:latest
MAINTAINER "Aleksa Sarai <cyphar@cyphar.com>"

# Make sure the repos and packages are up to date
RUN apk update && \
    apk upgrade && \
    apk add python3 git && \
    python3 -m ensurepip && \
    rm -rf /var/cache/apk

# Set up server user.
RUN adduser -s /bin/false -HDS -- drone

# Install Python requirements.
COPY requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt

# Set up cyphar.com server directory.
RUN mkdir -p -- /srv/www
WORKDIR /srv/www

# Set up cyphar.com and port config.
USER drone
EXPOSE 5000
ENTRYPOINT ["python3", "cyphar.py", "-H0.0.0.0", "-p5000"]
CMD []

# Copy over the cyphar.com app source.
# Do this last to preserve the cache.
COPY . /srv/www
