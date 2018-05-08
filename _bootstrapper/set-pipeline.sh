#!/bin/bash

set -eo pipefail
TARGET="pcf-pipelines"

case "$1" in
*)
	fly -t "$TARGET" set-pipeline \
		-p bootstrap:pcf-pipelines-selective-deploy \
		-c pipeline.yml \
		-l params.yml \
		"$@"
	;;
esac
