#!/bin/bash

set -eu
[ 'true' = "${DEBUG:-}" ] && set -x

echo "Downloading FLY from Concourse server $URL"
wget -O fly "$URL/api/v1/cli?arch=amd64&platform=linux"
chmod +x ./fly
export PATH="$PATH":$(pwd)

echo "FLY version in use:"
fly --version

echo "Logging into concourse $URL with team $TEAM"
fly -t "$TARGET" login -c "$URL" -n "$TEAM" -u "$USERNAME" -p "$PASSWORD"

cd pcf-pipelines

./set-pipelines.sh all -n
