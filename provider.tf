provider "aws" {
     alias  = "aws-assume"
     assume_role {
        role_arn     = var.map_ns_records ? data.aws_ssm_parameter.role[0].value : ""
 }
}
