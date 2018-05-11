#!/bin/bash

set -eu
[ 'true' = "${DEBUG:-}" ] && set -x

# Should the slug contain more than one product, pick only the first.
FILE_PATH=$(find ./pivnet-product -name "*.pivotal" | sort | head -1)

om-linux \
	--target "https://$OPSMAN_DOMAIN_OR_IP_ADDRESS" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--skip-ssl-validation \
	upload-product \
	--product "$FILE_PATH"
