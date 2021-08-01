TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
PROJECT = $(shell jq --raw-output .project ${TOP_DIR}/settings.tfvars.json)
GCP_PROJECT := $(shell jq --raw-output .gcp_project ${TOP_DIR}/settings.tfvars.json)
PREFIX := $(shell jq --raw-output .prefix ${TOP_DIR}/settings.tfvars.json)
REGION := $(shell jq --raw-output .region ${TOP_DIR}settings.tfvars.json)
VERSION := $(shell git describe --no-match --always --dirty=-dirty-$(shell date +%s))

run:	init_service
	cd ${TOP_DIR}/app && \
	yarn run start

send_events_via_pubsub:	init_client
	cd ${TOP_DIR}/client && \
	source ${TOP_DIR}/client/.venv/bin/activate && \
	export GCP_PROJECT=${GCP_PROJECT}; python3 -B ${TOP_DIR}/client/send_events_via_pubsub.py

build_service:	init_service
	cd ${TOP_DIR}/app && \
	yarn run build && \
	docker build -t ${PROJECT}:local .

push_service:	build_service
	cd ${TOP_DIR} && \
	docker tag ${PROJECT}:local ${REGION}-docker.pkg.dev/${GCP_PROJECT}/${PREFIX}${PROJECT}/${PREFIX}${PROJECT}-app:${VERSION}
	docker push ${REGION}-docker.pkg.dev/${GCP_PROJECT}/${PREFIX}${PROJECT}/${PREFIX}${PROJECT}-app:${VERSION}

run_service:	build_service
	cd ${TOP_DIR} && \
	docker run -ti --rm --rm --name=${PROJECT} -e GCP_PROJECT=${GCP_PROJECT} -p 127.0.0.1:8080:8080 ${PROJECT}:local

init:
	@if [ ! -f "${TOP_DIR}/settings.tfvars.json" ]; then \
		echo "settings.tfvars.json missing."; \
		exit 1; \
	fi

init_client:	init
	@cd ${TOP_DIR}/client && \
	if [ ! -d "${TOP_DIR}/client/.venv/" ]; then \
		virtualenv -p python3 ${TOP_DIR}/client/.venv/; \
	fi && \
	source ${TOP_DIR}/client/.venv/bin/activate && \
	pip install -r ./requirements.txt

init_service:	init
	@cd ${TOP_DIR}/app && \
	yarn install

deploy_resources:
	@cd ${TOP_DIR}/infra/resources && \
	terraform init -upgrade && \
	terraform apply -auto-approve -var-file="${TOP_DIR}/settings.tfvars.json"

deploy_services:	push_service
	@cd ${TOP_DIR}/infra/services && \
	terraform init -upgrade && \
	terraform apply -auto-approve -var="service_version=${VERSION}" -var-file="${TOP_DIR}/settings.tfvars.json"
