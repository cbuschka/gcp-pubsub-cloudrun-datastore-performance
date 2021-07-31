variable "project" {
  type = string
}
variable "gcp_project" {
type = string
}
variable "prefix" {
  type = string
  default = ""
}
variable "region" {
  type = string
}
variable "service_version" {
  type = string
}
variable "impersonators" {
  type = list(string)
  default = []
}

