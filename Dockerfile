###############################################
# Dockerfile for the cyphar.com flask server. #
# Based on ubuntu 13.10                       #
###############################################

# cyphar.com: my personal site's flask app
# Copyright (c) 2014 Cyphar

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

FROM ubuntu:13.10
MAINTAINER "cyphar <cyphar@cyphar.com>"

##################
# Update server. #
##################

# Make sure the repos and packages are up to date
RUN apt-get update
RUN apt-get upgrade -y

###########################################
# Install cyphar.com server dependencies. #
###########################################

# Install python3 and flask.
RUN apt-get install -y python3 python3-flask

#####################################
# Install and configure cyphar.com. #
#####################################

# Set up cyphar.com server directory.
RUN mkdir -p /srv/www /srv/db
WORKDIR /srv/www

# Copy over the cyphar.com app source.
ADD . /srv/www

# Generate database
RUN python3 db/initdb.py -d /srv/db/cyphar.db

# Set up cyphar.com and port config.
EXPOSE 80
CMD ["python3", "cyphar.py", "-H0.0.0.0", "-p80", "-d", "/srv/db/cyphar.db"]
