resource "google_pubsub_topic" "topic" {
  name = "${var.prefix}${var.project}-input"
  project = var.gcp_project
}

resource "google_pubsub_topic" "dead-letter-topic" {
  name = "${var.prefix}${var.project}-dlq"
  project = var.gcp_project
}
