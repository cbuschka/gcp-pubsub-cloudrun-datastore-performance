resource "google_artifact_registry_repository" "docker-registry" {
  provider = google-beta
  project = var.gcp_project
  location = var.region
  repository_id = "${var.prefix}${var.project}"
  description = "docker registry for ${var.project}"
  format = "DOCKER"
}
