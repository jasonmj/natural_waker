#!/usr/bin/env bash
set -e

cp -R /tmp/.ssh /home/nerves/.ssh
chmod 700 /home/nerves/.ssh

exec "$@"

cd /opt/app && /bin/bash
