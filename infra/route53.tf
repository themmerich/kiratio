resource "aws_route53_zone" "site" {
  name    = var.domain
  comment = "Kiratio-Website. Nameserver bei Strato auf die vier NS dieser Zone umstellen."
}

resource "aws_route53_record" "apex_a" {
  zone_id = aws_route53_zone.site.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "apex_aaaa" {
  zone_id = aws_route53_zone.site.zone_id
  name    = var.domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

# ALIAS statt CNAME, auch für www: Anfragen auf ALIAS-Records zur eigenen
# Distribution zählen nicht gegen das DNS-Kontingent des Tarifs.
resource "aws_route53_record" "www_a" {
  zone_id = aws_route53_zone.site.zone_id
  name    = local.www_domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_aaaa" {
  zone_id = aws_route53_zone.site.zone_id
  name    = local.www_domain
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

# ---------------------------------------------------------------------------
# E-Mail: vor der Nameserver-Umstellung ausfüllen.
#
# Sobald Strato nicht mehr für die DNS-Zone zuständig ist, beantwortet auch
# niemand mehr die MX-Anfragen für post@kiratio.de. Die bestehenden Einträge
# im Strato-Kundenlogin (MX, SPF im TXT-Record, DKIM, gegebenenfalls
# autodiscover) müssen vorher abgeschrieben und hier nachgebaut werden.
#
# resource "aws_route53_record" "mx" {
#   zone_id = aws_route53_zone.site.zone_id
#   name    = var.domain
#   type    = "MX"
#   ttl     = 3600
#   records = [
#     "10 mx00.kundenserver.de",
#     "20 mx01.kundenserver.de",
#   ]
# }
#
# resource "aws_route53_record" "spf" {
#   zone_id = aws_route53_zone.site.zone_id
#   name    = var.domain
#   type    = "TXT"
#   ttl     = 3600
#   records = ["v=spf1 include:... -all"]
# }
# ---------------------------------------------------------------------------
