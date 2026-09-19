# Der Flat-Rate-Tarif setzt ein zugeordnetes Web-ACL voraus, sonst lässt sich
# die Distribution nicht in den Tarif aufnehmen. Bewusst nur eine einzelne
# Regel und keine Rule Group: Rule Groups sind im Tarif nicht unterstützt.
resource "aws_wafv2_web_acl" "site" {
  provider = aws.us_east_1

  name        = "${var.project}-site"
  description = "Grundschutz für die Kiratio-Website."
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.rate_limit_per_5min
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project}-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-site"
    sampled_requests_enabled   = true
  }
}
