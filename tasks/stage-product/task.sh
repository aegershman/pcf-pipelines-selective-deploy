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

# I know, this is kind of bonkers. But here's the deal:
# We have to account for all these possible values (and maybe more?):
# product_version: '1.12.9-beta.11'
# product_version: 1.12.9-beta.11
# product_version: "1.12.9-beta.11"
# product_version: '1.12.9'
# product_version: 1.12.9
# product_version: "1.12.9"
# ... So that's what the weird tr -d is for
DESIRED_VERSION=$(
	cat metadata/*.yml |
		grep '^product_version' |
		cut -d' ' -f 2 |
		tr -d "'\""
)

om-linux \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--skip-ssl-validation \
	stage-product \
	--product-name "$PRODUCT_NAME" \
	--product-version "$DESIRED_VERSION"
