#!/bin/bash

set -eu
[ 'true' = "${DEBUG:-}" ] && set -x

STAGED=$(om-linux \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--skip-ssl-validation \
	curl \
	--path /api/v0/staged/products)

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
	--skip-ssl-validation \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	curl \
	--path /api/v0/installations \
	--request POST \
	--data "$DATA"
