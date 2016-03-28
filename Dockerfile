# cyphar.com: my personal site's flask app
# Copyright (C) 2014, 2015, 2016 Aleksa Sarai

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
