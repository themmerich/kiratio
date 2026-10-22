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
# E-Mail. Diese vier Einträge liefert Strato heute für die Zone aus, abgefragt
# am 22.10.2026 gegen docks12.rzone.de. Sie müssen hier stehen, bevor die
# Nameserver umgestellt werden: Danach beantwortet Strato keine Anfragen für
# die Domain mehr, auch nicht die für info@kiratio.de.
#
# Einen SPF-Eintrag hat die Zone derzeit nicht, deshalb steht hier auch keiner.
# Das DMARC steht auf p=reject, die Zustellung hängt damit allein an DKIM.
# ---------------------------------------------------------------------------

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.site.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = 3600
  records = ["5 smtpin.rzone.de"]
}

# Zwei DKIM-Schlüssel, RSA und ed25519. Ein einzelner TXT-String fasst nur 255
# Zeichen, der RSA-Schlüssel ist 410 lang. Die beiden Anführungszeichen in der
# Mitte teilen ihn in zwei Strings, die der Empfänger wieder zusammensetzt —
# genau so liefert Strato ihn auch aus. Die Stelle ist nicht frei wählbar,
# wer den Schlüssel neu setzt, muss nach 255 Zeichen trennen.
resource "aws_route53_record" "dkim_rsa" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "strato-dkim-0002._domainkey.${var.domain}"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAt3a1nbhQdD0MtbPT1r8DGZefoQlj3fSgtWdINsXsRl55OmOAf2QNR8B0SwC59dWqA+isuH/bQnU0f0OmO5A7p+cyfT9EekbWslP575NAnAYpsUJlBv/0O8qA6T/cLoDz6LsUYv000gFRqSSUe1BZnJ/sjg0f96UCkomT1aQRpSUSDwNYCqpQKQ/fWg9IS2fL+\"\"d2kR1rckqwoKdgbEtjr4i+ICn2SUodI1KkGusIivuBueMYfDh8RGYKvFv40UZlBSfuX71GkzEPvQPnQTfXLqM9F8q1kWq/mdWYy5R0KrWptAnuAmCZqujkgWmcqzLoTMln04oOxGFp/zkf8iA75lwIDAQAB"]
}

resource "aws_route53_record" "dkim_ed25519" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "strato-dkim-0003._domainkey.${var.domain}"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DKIM1; k=ed25519; p=hB4fidO1tsRNeRkj6ySb9N2xwfNzERRFYLQhGQyQ9dE="]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.site.zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = 3600
  records = ["v=DMARC1;p=reject;"]
}
