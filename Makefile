TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SHELL := /bin/bash
VENV_DIR = ${TOP_DIR}/.venv/
PROJECT = gpcdp

run:	init
	cd ${TOP_DIR} && \
	source ${VENV_DIR}/bin/activate && \
	source ${TOP_DIR}/projectrc && \
	PYTHONPATH=${TOP_DIR}; python3 -B app

build:	init

docker:
	cd ${TOP_DIR} && \
	source ${TOP_DIR}/projectrc && \
	docker build -t ${PROJECT}:local .

docker-push:	docker
	cd ${TOP_DIR} && \
	source ${TOP_DIR}/projectrc && \
	docker tag ${PROJECT}:local ${GCP_REGION}/${GCP_PROJECT}/${PROJECT}/${PREFIX}${PROJECT}-app:latest
	docker push ${GCP_REGION}/${GCP_PROJECT}/${PROJECT}/${PREFIX}${PROJECT}-app:latest

docker-run:	docker
	cd ${TOP_DIR} && \
	source ${TOP_DIR}/projectrc && \
	docker run -ti --rm -p 127.0.0.1:8080:8080 ${PROJECT}:local

init:
	if [ ! -f "${TOP_DIR}/projectrc" ]; then \
		echo "projectrc missing."; \
		exit 1; \
	fi; \
	if [ ! -d "${VENV_DIR}/" ]; then \
		virtualenv -p python3 ${VENV_DIR}/; \
	fi && \
	source ${VENV_DIR}/bin/activate && \
	pip install -r ${TOP_DIR}/requirements.txt
