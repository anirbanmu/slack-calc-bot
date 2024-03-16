#!/bin/sh

set -e

if [ -z "${RAILS_MASTER_KEY}" ]; then
    echo "RAILS_MASTER_KEY must be set"
    exit 1
fi

exec bundle exec rails s -p $PORT
