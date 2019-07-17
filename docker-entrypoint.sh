#!/bin/sh
set -e

if [ "$(which "$1")" = '' ]; then
  if [ "$(ls -A /usr/local/bundle/bin)" = '' ]; then
    echo 'command not in path and bundler not initialized'
    echo 'running bundle install'
    su-exec gem bundle install
  fi
fi

if [ "$1" = 'bundle' ]; then
  set -- su-exec gem "$@"
elif ls /usr/local/bundle/bin | grep -q "\b$1\b"; then
  set -- su-exec gem bundle exec "$@"

  su-exec gem ash -c 'bundle check || bundle install'
fi

exec "$@"
