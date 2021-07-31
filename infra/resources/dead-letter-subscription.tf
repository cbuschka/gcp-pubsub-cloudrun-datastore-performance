resource "google_pubsub_subscription" "dead-letter-subscription" {
  name = "${var.prefix}${var.project}-dead-letter-subscription"
  topic = google_pubsub_topic.dead-letter-topic.name
  project = var.gcp_project
  message_retention_duration = "1200s"
  retain_acked_messages = false
  ack_deadline_seconds = 20
}
