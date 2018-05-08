#!/bin/bash

set -eo pipefail
TARGET="pcf-pipelines"

case "$1" in

sandbox)
	cd foundations/sandbox/tiles
	for f in *; do
		PIPELINE_NAME=${f%.*}
		fly -t "$TARGET" set-pipeline \
			-p "sandbox:${PIPELINE_NAME}" \
			-c ../../../pipeline.yml \
			-l ../params.yml \
			-l "$f" \
			"$@"
	done
	;;

dev)
	cd foundations/dev/tiles
	for f in *; do
		PIPELINE_NAME=${f%.*}
		fly -t "$TARGET" set-pipeline \
			-p "dev:${PIPELINE_NAME}" \
			-c ../../../pipeline.yml \
			-l ../params.yml \
			-l "$f" \
			"$@"
	done
	;;

prod)
	cd foundations/prod/tiles
	for f in *; do
		PIPELINE_NAME=${f%.*}
		fly -t "$TARGET" set-pipeline \
			-p "prod:${PIPELINE_NAME}" \
			-c ../../../pipeline.yml \
			-l ../params.yml \
			-l "$f" \
			"$@"
	done
	;;

all)
	./set-pipelines.sh sandbox "$@"
	./set-pipelines.sh dev "$@"
	./set-pipelines.sh prod "$@"
	;;

*)
	echo "Usage: ./set-pipelines.sh <sandbox | dev | prod | all> [optional args]"
	exit 1
	;;
esac
