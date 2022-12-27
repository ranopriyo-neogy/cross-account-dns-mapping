resource "aws_route53_zone" "dev" {
  name = format("%s.%s",var.subdomain,var.root_domain)
  tags = var.tags
}

resource "aws_route53_record" "dev-ns" {
  count    = var.map_ns_records ? 1 : 0
  provider = aws.aws-assume
  zone_id  = data.aws_route53_zone.zone[0].id
  name     = format("%s.%s",var.subdomain,var.root_domain)
  type     = var.type
  ttl      = var.ttl
  records  = aws_route53_zone.dev.name_servers
}