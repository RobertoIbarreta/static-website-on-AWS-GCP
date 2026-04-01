output "s3_bucket_name" {
  value = aws_s3_bucket.site.bucket
}
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.site.domain_name
}
output "site_fqdn" {
  value = "${var.site_subdomain}.${var.domain_name}"
}
