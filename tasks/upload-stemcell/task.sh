#!/bin/bash

set -eu

[ 'true' = "${DEBUG:-}" ] && set -x

cd pcf-pipelines
export PATH="$PATH":$(pwd)
cd ..

if [[ -n "$NO_PROXY" ]]; then
	echo "$OM_IP $OPSMAN_DOMAIN_OR_IP_ADDRESS" >>/etc/hosts
fi

cd pivnet-product

SC_FILE_PATH=$(find ./ -name "*.tgz")

if [ ! -f "$SC_FILE_PATH" ]; then
	echo "Stemcell file not found!"
	exit 1
fi

# TODO building latest version of om-linux to get access to certain features
om-linux-venerable \
	--target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--username "$OPS_MGR_USR" \
	--password "$OPS_MGR_PWD" \
	--skip-ssl-validation \
	--request-timeout 3600 \
	upload-stemcell \
	--force \
	--floating="false" \
	--stemcell "$SC_FILE_PATH"
