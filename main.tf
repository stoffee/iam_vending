provider "vault" {
 address = var.vault_addr
 token = var.vault_token
}

provider "aws" {
  region = var.aws_region
#  access_key = data.vault_aws_access_credentials.creds.access_key
#  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

variable "vault_addr" {
    default = "https://vault-stoffee-io.vault.f4cfade2-df28-47f2-a365-28cd5d95d9a0.aws.hashicorp.cloud:8200"
}
variable "vault_token" {
}

variable "aws_region" {
    default = "us-west-2"
}

data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "route53"
}

resource "aws_iam_user" "vault" {
  name = "vault"
  tags = {
    tag-key = "vault-user"
  }
}

resource "aws_iam_access_key" "vault" {
  user = aws_iam_user.vault.name
}

data "aws_iam_policy_document" "vault_admin" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "vault_admin" {
  name = "vault"
  user = aws_iam_user.vault.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}