resource "google_storage_bucket" "tfstate_bucket" {
  project = var.gcp_project
  name = "${var.prefix}${var.project}-tfstate"
  location = var.region
  force_destroy = true
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}
