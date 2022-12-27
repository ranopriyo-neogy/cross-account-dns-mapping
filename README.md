# About

This Terraform configuration can be used create a Hosted Zone in AWS Account `A` and map it to the root domain in another AWS Account `B`. To make it more simple consider you manage multiple AWS account and have purchased `Route53` domain that resides in any specific AWS Account. The manual process would be to create a `hosted zone` in the account you want to run your application and map the `NS` records to the account which has the root domain.

This manual task is addressed by this automation which takes input in `init.auto.tfvars` 
The creation of `hosted zone` in the account where you plan to deploy your application was kept mandatory as a part of this automation, however the mapping of hosted zone to the main account which has the root domain was kept optional and can be disabled / enabled using `map_ns_records`

```
map_ns_records     = true
root_domain        = "provide-root-domain.com"  
subdomain          = "provide-subdomain"
ttl                = "30"
type               = "NS"
tags = {
  account_id = "00000000"
  env_id     = "dev"
  created_by = "terraform"
}
```

# Prerequisite 

The important point to note here is since we are trying to access a resource (Route53) from Account `A` to another Account `B` for mapping the `NS` records, we need to have access to account `B` from account `A`.

The access issue can be solved by creating an iam role in account `B` that has sufficient privilege to access to the resource (Route53) in account `B` and Account `A` should assume that role while trying to map the resource in Account `B` and the Role should permit that access.

You have to create a role manually in Account `B` that has access to `Route53` for mapping `NS` records. Then you have to store it in the deployment account Account `A` in a parameter store and refer the parameter store name in the `data.tf` file as shown below. In an AWS Organization structure this is addressed by `Stacksets` which will store the `Role ARN` in a `Parameter Store` that has access to `Route53` resource in `Account B` in `Account A` or any any account within the specific Organizational Unit (ou). We just have to make sure the Parameter Store name is passed to `data.tf`

```
data "aws_ssm_parameter" "role" {
  count= var.map_ns_records ? 1 : 0
  name = "AccountDnsArnName"
}
```

That being said here is the stackset that we used to store the role arn created in Account `B` to Account `A` or any account within the `ou` where we plan to run this terraform config. It basically has two parameters `AwsAccountNumber` and `AccountDnsArnName` which are basically the account number of `Account B` whoch has the root domain and `Role Arn` created manually that has access to Route53 domain in `Account B` for mapping the `NS` records.

```
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Distributed Parameter Store parameters",
  "Parameters": {
    "AwsAccountNumber": {
      "Description": "The AWS account number which has the root domain",
      "Type": "String"
    },
    "AccountDnsArnName": {
      "Description": "The role ARN for DNS zone access",
      "Type": "String",
      "Default": "AccountDnsArnName"
    }
  },
  "Resources": {
    "AccountDnsArn": {
      "Properties": {
        "AllowedPattern": "arn:aws:iam::[0-9-_]{12}:[a-zA-Z-]+(/)[a-zA-Z(_)]+",
        "DataType": "text",
        "Description": "SSM Parameter: assume role ARN for limited access to DNS domain.",
        "Name": {
          "Ref": "AccountDnsArnName"
        },
        "Tier": "Standard",
        "Type": "String",
        "Value": {
          "Fn::Sub": "arn:aws:iam::${AwsAccountNumber}:role/enter-role-name"
        }
      },
      "Type": "AWS::SSM::Parameter"
    }
  }
}

```

IAM Role cerated in Account `B` that has the root domain. This IAM role arn will be stored in Parameter Store of `Account A` using the above stackset and will be assumed while mapping `NS` records in `Account B` from `Account A`. Just make sure to update the `data.tf` file with the name of the Parameter Store in `Account A` having this role ARN. 

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GetAndList",
            "Effect": "Allow",
            "Action": "route53:ListHostedZones",
            "Resource": "*"
        },
        {
            "Sid": "GetAndListForChange",
            "Effect": "Allow",
            "Action": [
                "route53:ListTagsForResourc*",
                "route53:ListResourceRecordSets",
                "route53:GetHostedZone",
                "route53:GetChange"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/*",
                "arn:aws:route53:::change/*"
            ]
        },
        {
            "Sid": "ChangeResourceRecordSets",
            "Effect": "Allow",
            "Action": "route53:ChangeResourceRecordSets",
            "Resource": [
                "arn:aws:route53:::hostedzone/xyz",
                "arn:aws:route53:::hostedzone/pqrs",
                "arn:aws:route53:::change/zzz"
            ]
        }
    ]
}
```


Trust policy - To allow all account within a specific `ou` to assume the role for access to `Account B`. This will allow `Account A` to assume the Role created in `Account B`

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "trustpolicy",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "StringEquals": {
                    "aws:PrincipalOrgID": "o-ouid"
                }
            }
        }
    ]
}
```

The successful run of this terraform config will create a hosted zone in `Account A` and map it to the root domain in `Account B`

# Contributor
- [Ranopriyo Neogy](https://github.com/ranopriyo-neogy)