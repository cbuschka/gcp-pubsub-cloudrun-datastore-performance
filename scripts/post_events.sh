#!/bin/bash

TOP_DIR=$(cd `dirname $0`/.. && pwd -P)

GCP_PROJECT=$(jq --raw-output .gcp_project ${TOP_DIR}/settings.tfvars.json)
PROJECT=$(jq --raw-output .project ${TOP_DIR}/settings.tfvars.json)
PREFIX=$(jq --raw-output .prefix ${TOP_DIR}/settings.tfvars.json)

count=3
items=$(for i in $(seq 1 ${count}); do u=${RANDOM}; echo -n "{\"id\":\"$u\",\"value\":\"$(date)\"},"; done; u=${RANDOM}; echo -n "{\"id\":\"$u\",\"value\":\"$(date)\"}")
message="{\"items\":[${items}]}"
echo "Message is $message"
echo "${message}"|jq
message_base64=$(echo "$message" | base64  | perl -pe 's#\n|\r##g')
echo "${message_base64}"
pubsub_message="{\"message\":{\"data\":\"${message_base64}\"}}"
echo "${pubsub_message}"|jq

case `basename $0 .sh` in
  post_events)
    curl -X POST https://conni-gcp-pubsub-cloudrun-pyasyncio-hyogknauxq-ey.a.run.app/events -d "${pubsub_message}"
    ;;
  post_events_via_pubsub)
    gcloud config set project ${GCP_PROJECT}
    gcloud pubsub topics publish ${PREFIX}${PROJECT}-input --message="${message}"
    ;;
  *)
    echo "dontknow"
    ;;
esac

