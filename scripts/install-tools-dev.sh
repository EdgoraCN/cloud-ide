#!/bin/bash
apt-get update
apt-get -y install git build-essential curl   xz-utils openssl net-tools gnupg2 ca-certificates && \
apt-get install -y locales && \
locale-gen en_US.UTF-8 && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/*
# Locale Generation
# We unfortunately cannot use update-locale because docker will not use the env variables
# configured in /etc/default/locale so we need to set it manually.