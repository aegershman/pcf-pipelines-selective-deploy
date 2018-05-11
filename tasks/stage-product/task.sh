#!/bin/bash

[ 'true' = "${DEBUG:-}" ] && set -x

desired_version=$(jq --raw-output '.Release.Version' <./pivnet-product/metadata.json)

AVAILABLE=$(
	om-linux \
		--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
		--client-id "${OPSMAN_CLIENT_ID}" \
		--client-secret "${OPSMAN_CLIENT_SECRET}" \
		--skip-ssl-validation \
		curl \
		--path /api/v0/available_products
)

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

DEPLOYED=$(
	om-linux \
		--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
		--client-id "${OPSMAN_CLIENT_ID}" \
		--client-secret "${OPSMAN_CLIENT_SECRET}" \
		--skip-ssl-validation \
		deployed-products
)
DEPLOYED=${DEPLOYED//\|/}

if grep -q "$PRODUCT_NAME $desired_version" <<<"$DEPLOYED"; then
	echo "Desired version ${desired_version} is already deployed of tile ${PRODUCT_NAME}"
	exit 0
fi

# Figure out which products are unstaged.
UNSTAGED_ALL=$(
	jq \
		-n \
		--argjson available "$AVAILABLE" \
		--argjson staged "$STAGED" \
		'$available - ($staged | map({"name": .type, "product_version": .product_version}))'
)

UNSTAGED_PRODUCT=$(
	jq \
		-n \
		"$UNSTAGED_ALL" |
		jq \
			"map(select(.name == \"$PRODUCT_NAME\")) | map(select(.product_version|startswith(\"$desired_version\")))"
)

# There should be only one such unstaged product.
if [ "$(echo $UNSTAGED_PRODUCT | jq '. | length')" -ne "1" ]; then
	echo "Need exactly one unstaged build for $PRODUCT_NAME version $desired_version"
	jq -n "$UNSTAGED_PRODUCT"
	exit 1
fi

full_version=$(echo "$UNSTAGED_PRODUCT" | jq -r '.[].product_version')

om-linux \
	--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
	--client-id "${OPSMAN_CLIENT_ID}" \
	--client-secret "${OPSMAN_CLIENT_SECRET}" \
	--skip-ssl-validation \
	stage-product \
	--product-name "${PRODUCT_NAME}" \
	--product-version "${full_version}"
