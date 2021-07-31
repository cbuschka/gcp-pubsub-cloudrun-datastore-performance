resource "google_app_engine_application" "app" {
  count = 0
  project = var.gcp_project
  location_id = var.region
  database_type = "CLOUD_DATASTORE_COMPATIBILITY"
}
