###############################################
# Dockerfile for the cyphar.com flask server. #
# Based on ubuntu 13.10                       #
###############################################

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
RUN mkdir -p /srv/cyphar.com
WORKDIR /srv/cyphar.com

# Copy over the cyphar.com app source.
ADD . /srv/cyphar.com

# Set up cyphar.com and port config.
EXPOSE 80
CMD ["python3", "cyphar.py", "-H0.0.0.0", "-p80"]
