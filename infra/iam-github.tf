# GitHub Actions meldet sich per OpenID Connect an und übernimmt eine Rolle.
# Damit liegen keine dauerhaften Zugangsschlüssel im Repository.
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? one(aws_iam_openid_connect_provider.github[*].arn) : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"

  github_owner     = split("/", var.github_repository)[0]
  github_repo_name = split("/", var.github_repository)[1]
}

data "aws_iam_policy_document" "deploy_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Nur dieses Repository und nur dieser Branch. Ein Pull Request aus einem
    # Fork bekommt die Rolle damit nicht.
    #
    # Zwei Schreibweisen, weil GitHub den sub-Claim auf eine Form umstellt, die
    # zusätzlich die numerischen IDs von Konto und Repository trägt. Die hängen
    # nicht am Namen und überleben damit eine Umbenennung. Welche Form ein Lauf
    # schickt, entscheidet GitHub; wer nur die Namensform einträgt, bekommt ein
    # "Not authorized to perform sts:AssumeRoleWithWebIdentity".
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repository}:ref:refs/heads/${var.deploy_branch}",
        "repo:${local.github_owner}@${var.github_owner_id}/${local.github_repo_name}@${var.github_repository_id}:ref:refs/heads/${var.deploy_branch}",
      ]
    }
  }
}

data "aws_iam_policy_document" "deploy" {
  statement {
    sid       = "BucketAuflisten"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.site.arn]
  }

  statement {
    sid       = "DateienSchreiben"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }

  statement {
    sid       = "CacheLeeren"
    actions   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation"]
    resources = [aws_cloudfront_distribution.site.arn]
  }
}

resource "aws_iam_role" "deploy" {
  name               = "${var.project}-github-deploy"
  description        = "Deploy der Website aus GitHub Actions."
  assume_role_policy = data.aws_iam_policy_document.deploy_assume.json
}

resource "aws_iam_role_policy" "deploy" {
  name   = "${var.project}-deploy"
  role   = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy.json
}
