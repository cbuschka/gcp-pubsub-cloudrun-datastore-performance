TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
VENV_DIR = ${TOP_DIR}/.venv/
PROJECT = $(shell jq --raw-output .project ${TOP_DIR}/settings.tfvars.json)
GCP_PROJECT := $(shell jq --raw-output .gcp_project ${TOP_DIR}/settings.tfvars.json)
PREFIX := $(shell jq --raw-output .prefix ${TOP_DIR}/settings.tfvars.json)
REGION := $(shell jq --raw-output .region ${TOP_DIR}settings.tfvars.json)
VERSION := $(shell git describe --no-match --always --dirty=-dirty-$(shell date +%s))

run:	init
	cd ${TOP_DIR} && \
	source ${VENV_DIR}/bin/activate && \
	export GCP_PROJECT=${GCP_PROJECT}; PYTHONPATH=${TOP_DIR}; python3 -B app

send_events_via_pubsub:	init
	cd ${TOP_DIR} && \
	source ${VENV_DIR}/bin/activate && \
	export GCP_PROJECT=${GCP_PROJECT}; PYTHONPATH=${TOP_DIR}; python3 -B ${TOP_DIR}/client/send_events_via_pubsub.py

build:	init

build_service:
	cd ${TOP_DIR} && \
	docker build -t ${PROJECT}:local .

push_service:	build_service
	cd ${TOP_DIR} && \
	docker tag ${PROJECT}:local ${REGION}-docker.pkg.dev/${GCP_PROJECT}/${PREFIX}${PROJECT}/${PREFIX}${PROJECT}-app:${VERSION}
	docker push ${REGION}-docker.pkg.dev/${GCP_PROJECT}/${PREFIX}${PROJECT}/${PREFIX}${PROJECT}-app:${VERSION}

run_service:	build_service
	cd ${TOP_DIR} && \
	docker run -ti --rm -e GCP_PROJECT=${GCP_PROJECT} -p 127.0.0.1:8080:8080 ${PROJECT}:local

init:
	if [ ! -f "${TOP_DIR}/settings.tfvars.json" ]; then \
		echo "settings.tfvars.json missing."; \
		exit 1; \
	fi; \
	if [ ! -d "${VENV_DIR}/" ]; then \
		virtualenv -p python3 ${VENV_DIR}/; \
	fi && \
	source ${VENV_DIR}/bin/activate && \
	pip install -r ${TOP_DIR}/requirements.txt

deploy_resources:
	@cd ${TOP_DIR}/infra/resources && \
	terraform init -upgrade && \
	terraform apply -auto-approve -var-file="${TOP_DIR}/settings.tfvars.json"

deploy_services:	push_service
	@cd ${TOP_DIR}/infra/services && \
	terraform init -upgrade && \
	terraform apply -auto-approve -var="service_version=${VERSION}" -var-file="${TOP_DIR}/settings.tfvars.json"
