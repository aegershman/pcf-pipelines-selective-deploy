#!/bin/bash

set -exo pipefail
TARGET="pcf-pipelines"

case "$1" in
*)
	cd tiles
	for f in *; do
		PIPELINE_NAME=${f%.*}
		fly -t "$TARGET" \
			set-pipeline -p "upgrade-${PIPELINE_NAME}" \
			-c ../pipeline.yml \
			-l ../params.yml \
			-l "$f"
	done
	;;
esac
