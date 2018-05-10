#!/bin/bash

./om-darwin \
	--target $TARGET \
	--client-id $USERNAME \
	--client-secret $SECRET \
	--skip-ssl-validation \
	curl \
	--request PATCH \
	--path /api/v0/stemcell_assignments \
	--data '
		{
		"products": [
				{
					"guid":"Pivotal_Single_Sign-On_Service-24ca14abf676bdcd673d",
					"staged_stemcell_version": "3445.44"
				}
			]
		}
		'
