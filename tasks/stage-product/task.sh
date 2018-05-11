#!/bin/bash

set -eu
[ 'true' = "${DEBUG:-}" ] && set -x

# Should the slug contain more than one product, pick only the first.
FILE_PATH=$(find ./pivnet-product -name "*.pivotal" | sort | head -1)
unzip "$FILE_PATH" metadata/*

PRODUCT_NAME="$(
	cat metadata/*.yml |
		grep '^name' |
		cut -d' ' -f 2
)"

DESIRED_VERSION=$(
	cat metadata/*.yml |
		grep '^product_version' |
		cut -d' ' -f 2
)

om-linux \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--skip-ssl-validation \
	stage-product \
	--product-name "$PRODUCT_NAME" \
	--product-version "$DESIRED_VERSION"
