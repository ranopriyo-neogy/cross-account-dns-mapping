variable "root_domain" {
    type = string
    default = ""
    description = "(Required) The registered Route53 Domain present in main account"
}

variable "subdomain" {
    type = string
    default = ""
    description = "(Required) Unique URL that lives on your purchased domain as an extension in front of your regular domain like www OR xyz etc"
}

variable "ttl" {
    type = number
    default=30
    description = "(Required for non-alias records) The TTL of the record"
}

variable "type" {
    type = string
    default = null
    description = "(Required) The record type. Valid values are A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT"
}

variable "tags" {
  type    = map(string)
  default = {}
  description = "Tags for the resource"
}

variable "map_ns_records" {
    type = bool
    default = false
    description = "Enable this flag if you want to map NS records to specific domains in your account which has the Root Domain"
}