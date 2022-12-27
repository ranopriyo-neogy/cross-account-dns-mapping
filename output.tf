output "hosted_zones" {
  value       = format("%s.%s",var.subdomain,var.root_domain)
  description = "Created Hosted Zone"
}

output "mapped_ns_records" {
  value       = var.map_ns_records ? aws_route53_zone.dev.name_servers : ["Please go ahead with Manual Mapping"]
  description = "Mapped NS Records in Publishing Account"
}
