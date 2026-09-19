output "nameserver" {
  description = "Diese vier Nameserver im Strato-Kundenlogin als eigene Nameserver eintragen."
  value       = aws_route53_zone.site.name_servers
}

output "bucket" {
  description = "Wert für die Repository-Variable AWS_SITE_BUCKET."
  value       = aws_s3_bucket.site.bucket
}

output "distribution_id" {
  description = "Wert für die Repository-Variable AWS_DISTRIBUTION_ID."
  value       = aws_cloudfront_distribution.site.id
}

output "deploy_role_arn" {
  description = "Wert für das Repository-Secret AWS_DEPLOY_ROLE_ARN."
  value       = aws_iam_role.deploy.arn
}

output "distribution_domain" {
  description = "Direkte CloudFront-Adresse, nützlich zum Testen vor der DNS-Umstellung."
  value       = aws_cloudfront_distribution.site.domain_name
}
