provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  site_fqdn = "${var.site_subdomain}.${var.domain_name}"
  labels = merge(
    {
      managed_by = "terraform"
      project    = var.project_name
    },
    var.labels
  )
}


resource "google_storage_bucket" "site" {
  name                        = "${var.project_name}-${replace(local.site_fqdn, ".", "-")}-site"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "inherited"
  force_destroy               = false
  labels                      = local.labels
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "public_read" {
  bucket = google_storage_bucket.site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_backend_bucket" "site" {
  name        = "${var.project_name}-backend-bucket"
  bucket_name = google_storage_bucket.site.name
  enable_cdn  = true
}


resource "google_compute_managed_ssl_certificate" "site" {
  name = "${var.project_name}-managed-cert"
  managed {
    domains = [local.site_fqdn, var.domain_name]
  }
}

resource "google_compute_url_map" "https_map" {
  name            = "${var.project_name}-https-map"
  default_service = google_compute_backend_bucket.site.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.project_name}-https-proxy"
  url_map          = google_compute_url_map.https_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.site.id]
}


resource "google_compute_global_address" "site_ip" {
  name = "${var.project_name}-global-ip"
}


resource "google_compute_global_forwarding_rule" "https_rule" {
  name       = "${var.project_name}-https-fr"
  ip_address = google_compute_global_address.site_ip.address
  port_range = "443"
  target     = google_compute_target_https_proxy.https_proxy.id
}

resource "google_compute_url_map" "http_redirect" {
  name = "${var.project_name}-http-redirect-map"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "${var.project_name}-http-proxy"
  url_map = google_compute_url_map.http_redirect.id
}

resource "google_compute_global_forwarding_rule" "http_rule" {
  name       = "${var.project_name}-http-fr"
  ip_address = google_compute_global_address.site_ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.http_proxy.id
}

resource "google_dns_record_set" "apex_a" {
  name         = "${var.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_managed_zone
  rrdatas      = [google_compute_global_address.site_ip.address]
}

resource "google_dns_record_set" "www_a" {
  name         = "${local.site_fqdn}."
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_managed_zone
  rrdatas      = [google_compute_global_address.site_ip.address]
}
