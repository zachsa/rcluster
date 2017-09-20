#!/bin/sh
mkdir /var/log/couchdb
chown couchdb:couchdb /var/log/couchdb

apt-get update
apt-get install runit -y

mkdir /etc/sv/couchdb
mkdir /etc/sv/couchdb/log