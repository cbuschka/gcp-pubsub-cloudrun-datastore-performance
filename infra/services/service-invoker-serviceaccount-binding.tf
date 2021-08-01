data "google_service_account" "service-invoker" {
  account_id = "${var.prefix}${var.project}-service-invoker"
  project = var.gcp_project
}

resource "google_cloud_run_service_iam_binding" "service-invoker-run-invoker-binding" {
  location = var.region
  project = var.gcp_project
  service = google_cloud_run_service.service.name
  role = "roles/run.invoker"
  members = [
    "allUsers", // public access!!!
    "serviceAccount:${var.prefix}${var.project}-service-invoker@${var.gcp_project}.iam.gserviceaccount.com",
  ]
}
