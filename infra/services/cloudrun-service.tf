resource "google_cloud_run_service" "service" {
  name = "${var.prefix}${var.project}-service"
  location = var.region
  project = var.gcp_project
  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.gcp_project}/${var.prefix}${var.project}/${var.prefix}${var.project}-app:${var.service_version}"
        env {
          name = "GCP_PROJECT"
          value = var.gcp_project
        }
      }
      service_account_name = data.google_service_account.service-invoker.email
    }
  }

  traffic {
    percent = 100
    latest_revision = true
  }
}
