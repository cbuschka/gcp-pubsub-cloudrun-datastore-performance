# GCP Pubsub/Cloudrun/Datastore-Performance Benchmark

## Prerequisites

* bash
* GNU make
* terraform with version .terraform-version or better tfvm (https://github.com/cbuschka/tfvm)
* python 3
* gcloud sdk

## Setup

### Configure current project

```
gcloud config set project your-gcp-project-identifier
```

cp settings.tfvars.json.example to settings.tfvars.json and adjust accordingly.

### Login to gcp

```
gcloud auth login
gcloud auth application-default login
gcloud auth configure-docker <your region from settings.tfvars.json>-docker.pkg.dev
```

## Usage

### Deploy resources
```
make deploy_resources
```

### Deploy services
```
make deploy_services
```

### Send events

```
make send_events_via_pubsub
```

## License

[MIT-0](./license.txt)
