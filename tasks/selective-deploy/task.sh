#!/bin/bash

set -eu
[ 'true' = "${DEBUG:-}" ] && set -x

STAGED=$(
	om-linux \
		--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
		--client-id "${OPSMAN_CLIENT_ID}" \
		--client-secret "${OPSMAN_CLIENT_SECRET}" \
		--skip-ssl-validation \
		curl \
		--path /api/v0/staged/products
)

# Should the slug contain more than one product, pick only the first.
FILE_PATH=$(find ./pivnet-product -name "*.pivotal" | sort | head -1)
unzip "$FILE_PATH" metadata/*

PRODUCT_NAME="$(cat metadata/*.yml | grep '^name' | cut -d' ' -f 2)"

RESULT=$(echo "$STAGED" | jq \
	--arg product_name "$PRODUCT_NAME" \
	'map(select(.type == $product_name)) | .[].guid')

# TODO cleanup these jq statements
DATA=$(echo '{"deploy_products": []}' | jq ".deploy_products += [$RESULT]")

om-linux \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--skip-ssl-validation \
	curl \
	--path /api/v0/installations \
	--request POST \
	--data "$DATA"

# This *should* reattach the log stream to the current apply-changes job
# We shouldn't have to parse the "installation_id" returned from the POST
# above; we should be able to just do "apply-changes" and instead of it
# actually applying changes, it reattaches to the log stream... Hopefully?
#
# Also, just in case this does screw up somehow, we're passing in
# skip-deploy-products in the hopes that it only applies changes
# to the director & not the entire foundation. That shouldn't happen,
# but just in case...
om-linux \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--skip-ssl-validation \
	apply-changes \
	--skip-deploy-products="true"
