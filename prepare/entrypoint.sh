#!/bin/sh
set -e

if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
  exec supervisord -n "$@"
else
  supervisord -c /etc/supervisor/conf.d/supervisord.conf &
  exec "$@"
fi
