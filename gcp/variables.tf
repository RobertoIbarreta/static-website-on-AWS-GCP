variable "project_id" {
  description = "GCP project ID"
  type        = string
}
variable "region" {
  description = "Region for bucket location"
  type        = string
  default     = "asia-southeast1"
}
variable "project_name" {
  description = "Project name prefix"
  type        = string
}
variable "domain_name" {
  description = "Apex domain, e.g. example.com"
  type        = string
}
variable "site_subdomain" {
  description = "Site subdomain, e.g. www"
  type        = string
  default     = "www"
}
variable "dns_managed_zone" {
  description = "Existing Cloud DNS managed zone name (not DNS name)"
  type        = string
}
variable "labels" {
  description = "Common labels"
  type        = map(string)
  default     = {}
}
