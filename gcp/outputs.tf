output "bucket_name" {
  value = google_storage_bucket.site.name
}

output "global_ip_address" {
  value = google_compute_global_address.site_ip.address
}

output "site_fqdn" {
  value = "${var.site_subdomain}.${var.domain_name}"
}
