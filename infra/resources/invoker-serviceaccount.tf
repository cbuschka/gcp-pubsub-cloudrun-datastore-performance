resource "google_service_account" "service-invoker" {
  account_id = "${var.prefix}${var.project}-service-invoker"
  project = var.gcp_project
}

locals {
  roles = [
    "roles/artifactregistry.reader",
    "roles/datastore.user",
    "roles/pubsub.editor",
    "roles/pubsub.publisher",
    "roles/pubsub.subscriber",
    "roles/logging.admin"
  ]
}

resource "google_project_iam_member" "service-invoker-permission" {
  member = "serviceAccount:${google_service_account.service-invoker.email}"
  for_each = toset(local.roles)
  role = each.value
  project = var.gcp_project
}

