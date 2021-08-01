terraform {
  backend "gcs" {
    prefix = "resources"
  }
}
