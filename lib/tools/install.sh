#!/bin/sh

# Install GCC collection (GNU make and GNU compiler tools)
apt-get update
apt-get install build-essential -y

# Update openssl to 1.0.2l
# cd /usr/src
# wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz
# tar -zxf openssl-1.0.2l.tar.gz
# cd openssl-1.0.2l
# ./config
# make
# make test
# make install
# mv /usr/bin/openssl /root/
# ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl

# Python
apt-get update
apt-get install python -y

# libcurl
apt-get update
apt-get install libcurl4-openssl-dev -y

# ICU
apt-get update
apt-get install libicu-dev -y