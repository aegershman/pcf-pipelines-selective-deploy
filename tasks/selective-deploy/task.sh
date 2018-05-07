#!/bin/bash

set -euo pipefail

STAGED=$(om-linux \
	--skip-ssl-validation \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--username "${OPSMAN_USERNAME}" \
	--password "${OPSMAN_PASSWORD}" \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	curl -path /api/v0/staged/products)

# Should the slug contain more than one product, pick only the first.
FILE_PATH=$(find ./pivnet-product -name *.pivotal | sort | head -1)
unzip $FILE_PATH metadata/*

PRODUCT_NAME="$(cat metadata/*.yml | grep '^name' | cut -d' ' -f 2)"

RESULT=$(echo "$STAGED" | jq \
	--arg product_name "$PRODUCT_NAME" \
	'map(select(.type == $product_name)) | .[].guid')

DATA=$(echo '{"deploy_products": []}' | jq ".deploy_products += [$RESULT]")

om-linux --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--skip-ssl-validation \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--username "${OPSMAN_USERNAME}" \
	--password "${OPSMAN_PASSWORD}" \
	curl \
	--path /api/v0/installations \
	--request POST \
	--data "$DATA"

om-linux --target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--skip-ssl-validation \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--username "${OPSMAN_USERNAME}" \
	--password "${OPSMAN_PASSWORD}" \
	curl \
	--path /api/v0/installations/current_log
