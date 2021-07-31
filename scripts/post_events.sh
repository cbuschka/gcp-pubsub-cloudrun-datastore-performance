#!/bin/bash

count=1000
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
    gcloud pubsub topics publish conni-gcp-pubsub-cloudrun-pyasyncio-input --message="${message}"
    ;;
  *)
    echo "dontknow"
    ;;
esac

