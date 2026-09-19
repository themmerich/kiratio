terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Der State liegt zunächst lokal. Soll er geteilt werden, hier ein
  # S3-Backend eintragen und einmal `terraform init -migrate-state` laufen lassen.
  # backend "s3" {
  #   bucket = "..."
  #   key    = "kiratio/terraform.tfstate"
  #   region = "eu-central-1"
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

# CloudFront nimmt ACM-Zertifikate und WAF-Web-ACLs nur aus us-east-1 an,
# unabhängig davon, in welcher Region der Bucket liegt.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = local.tags
  }
}
