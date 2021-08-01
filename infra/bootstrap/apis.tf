locals {
  apis = [
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "service" {
  project = var.gcp_project
  for_each = toset(local.apis)
  service = each.value
  disable_dependent_services = false
  disable_on_destroy = false
}
