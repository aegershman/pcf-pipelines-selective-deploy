#!/bin/bash

set -eu
[ 'true' = "${DEBUG:-}" ] && set -x

# TODO: using latest built version of om-linux to get access to certain features which aren't quite released yet
export PATH="$PATH":$(pwd)/pcf-pipelines

# 1 Must extract the stemcell version from the pivnet-product passed in.
STEMCELL_VERSION=$(cat stemcell/metadata.json |
	jq \
		--raw-output \
		'.Release.Version'
)

# 2 Must extract the product GUID of what we're targeting
STAGED=$(om-linux \
	--target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--username "$OPS_MGR_USR" \
	--password "$OPS_MGR_PWD" \
	--skip-ssl-validation \
	curl -path /api/v0/staged/products)

# Should the slug contain more than one product, pick only the first.
FILE_PATH=$(find ./pivnet-product -name "*.pivotal" | sort | head -1)
unzip "$FILE_PATH" metadata/*

PRODUCT_NAME="$(cat metadata/*.yml |
	grep '^name' |
	cut -d' ' -f 2
)"

PRODUCT_GUID=$(echo "$STAGED" |
	jq \
		--arg product_name "$PRODUCT_NAME" \
		'map(select(.type == $product_name)) | .[].guid'
)

DATA=$(jq \
	--null-input \
	--arg guid "$PRODUCT_GUID" \
	--arg stemcell_version "$STEMCELL_VERSION" \
	'
		{
		"products": [
				{
					"guid": $guid,
					"staged_stemcell_version": $stemcell_version
				}
			]
		}
	'
)

# TODO: using latest built version of om-linux to get access to certain features which aren't quite released yet
./om-linux-venerable \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--username "$OPS_MGR_USR" \
	--password "$OPS_MGR_PWD" \
	--skip-ssl-validation \
	--request-timeout 3600 \
	curl \
	--request PATCH \
	--path /api/v0/stemcell_assignments \
	--data "$DATA"
