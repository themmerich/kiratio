resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.project}-site"
  description                       = "Zugriff der Distribution auf den privaten Bucket."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_function" "redirect_www" {
  name    = "${var.project}-redirect-www"
  runtime = "cloudfront-js-2.0"
  comment = "www auf die Wurzeldomain umleiten"
  publish = true

  code = templatefile("${path.module}/functions/redirect-www.js", {
    apex_domain = var.domain
    www_domain  = local.www_domain
  })
}

resource "aws_cloudfront_response_headers_policy" "site" {
  name    = "${var.project}-site"
  comment = "Sicherheitsheader für eine Seite ohne JavaScript und ohne Fremdinhalte."

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      # preload bewusst aus: Der Eintrag in die Browser-Preload-Liste ist ein
      # separater Schritt und praktisch nicht rückgängig zu machen.
      preload  = false
      override = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }

    # Die ausgelieferten Seiten haben kein JavaScript, keine Inline-Styles und
    # laden nichts von fremden Servern. Kommen später selbst gehostete Schriften
    # oder Fotos dazu, deckt 'self' das bereits ab.
    content_security_policy {
      content_security_policy = "default-src 'none'; style-src 'self'; img-src 'self' data:; font-src 'self'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'"
      override                = true
    }
  }

  custom_headers_config {
    items {
      header   = "Permissions-Policy"
      value    = "geolocation=(), camera=(), microphone=(), payment=()"
      override = true
    }
  }
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Kiratio-Website"
  default_root_object = "index.html"
  aliases             = [var.domain, local.www_domain]
  web_acl_id          = aws_wafv2_web_acl.site.arn

  # Europa und Nordamerika reichen für eine mainfränkische Zielgruppe.
  price_class = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-site"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-site"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.site.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_www.arn
    }
  }

  # Der Bucket ist privat, deshalb antwortet S3 auf eine unbekannte Datei mit
  # 403 statt 404. Beide Fälle führen auf dieselbe Fehlerseite.
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.site.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
