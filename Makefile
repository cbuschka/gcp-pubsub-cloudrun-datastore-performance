TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
VENV_DIR = ${TOP_DIR}/.venv/
PROJECT = gpcdp
GCP_PROJECT := $(shell jq --raw-output .project ${TOP_DIR}/settings.tfvars.json)
PREFIX := $(shell jq --raw-output .prefix ${TOP_DIR}/settings.tfvars.json)
REGION := $(shell jq --raw-output .region ${TOP_DIR}settings.tfvars.json)
VERSION := $(shell git describe --no-match --always --dirty=-dirty-$(shell date +%s))

run:	init
	cd ${TOP_DIR} && \
	source ${VENV_DIR}/bin/activate && \
	source ${TOP_DIR}/projectrc && \
	PYTHONPATH=${TOP_DIR}; python3 -B app

build:	init

docker:
	cd ${TOP_DIR} && \
	docker build -t ${PROJECT}:local .

docker-push:	docker
	cd ${TOP_DIR} && \
	docker tag ${PROJECT}:local ${GCP_REGION}/${GCP_PROJECT}/${PREFIX}${PROJECT}/${PREFIX}${PROJECT}-app:${VERSION}
	docker push ${GCP_REGION}/${GCP_PROJECT}/${PREFIX}${PROJECT}/${PREFIX}${PROJECT}-app:${VERSION}

docker-run:	docker
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
