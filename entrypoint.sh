#!/bin/sh

set -e

if [ -z "${SLACK_SIGNING_SECRET}" ]; then
    echo "SLACK_SIGNING_SECRET must be set"
    exit 1
fi

if [ -z "${SLACK_BOT_ACCESS_TOKEN}" ]; then
    echo "SLACK_BOT_ACCESS_TOKEN must be set"
    exit 1
fi

exec bundle exec rails s -p $PORT
