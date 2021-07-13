provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}
resource "aws_acm_certificate" "cert" {
  provider                  = "aws.acm"
  domain_name               = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.domain
  }
  depends_on = [aws_route53_zone.dev]
}