#!/bin/bash
set -e

if [ ! -d /home/root ]; then
  cp -r /root /home/root
fi

echo "Starting SSH ..."
service ssh start

echo "Starting Apache2 ..."
apachectl -D FOREGROUND