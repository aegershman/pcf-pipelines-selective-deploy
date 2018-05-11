#!/bin/bash

set -eu
[ 'true' = "${DEBUG:-}" ] && set -x

# TODO: using latest built version of om-linux to get access to certain features which aren't quite released yet
export PATH="$PATH":$(pwd)/pcf-pipelines

cd stemcell/

SC_FILE_PATH=$(find ./ -name "*.tgz")

if [ ! -f "$SC_FILE_PATH" ]; then
	echo "Stemcell file not found!"
	exit 1
fi

# TODO: using latest built version of om-linux to get access to certain features which aren't quite released yet
om-linux-venerable \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--skip-ssl-validation \
	--request-timeout 3600 \
	upload-stemcell \
	--force \
	--floating="false" \
	--stemcell "$SC_FILE_PATH"
