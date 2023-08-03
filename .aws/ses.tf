resource "aws_ses_email_identity" "email" {
  email = var.your_email
}

resource "aws_ses_domain_identity" "example" {
  domain = var.your_email_domain
}