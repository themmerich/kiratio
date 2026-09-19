data "aws_caller_identity" "current" {}

locals {
  www_domain  = "www.${var.domain}"
  bucket_name = "${var.project}-site-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project   = var.project
    ManagedBy = "terraform"
  }
}
