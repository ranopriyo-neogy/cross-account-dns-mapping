data "aws_ssm_parameter" "role" {
  count= var.map_ns_records ? 1 : 0
  name = "AccountDnsArnName"
}

data "aws_route53_zone" "zone" {
  count= var.map_ns_records ? 1 : 0
  name         = var.root_domain
  provider     = aws.aws-assume
}