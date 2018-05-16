#!/bin/bash

set -eu

function main() {

	local cwd
	cwd="${1}"

	om-linux \
		--target "https://${OPSMAN_DOMAIN_OR_IP_ADDRESS}" \
		--skip-ssl-validation \
		--client-id "${OPSMAN_CLIENT_ID}" \
		--client-secret "${OPSMAN_CLIENT_SECRET}" \
		export-installation \
		--output-file \
		"${cwd}/opsmgr-settings/${OPSMAN_SETTINGS_FILENAME}"

}

main "${PWD}"
