provider "google" {
  alias   = "default"
  project = var.gcp_project
}

provider "google-beta" {
  alias   = "google-beta"
  project = var.gcp_project
}
