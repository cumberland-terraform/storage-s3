provider "aws" {
    region                  = "us-east-1"
    assume_role {
        role_arn            = "arn:aws:iam::798223307841:role/IMR-MDT-TERA-EC2"
    }
}

variables {
    platform                                = {
        aws_region                          = "US EAST 1"
        account                             = "ID ENGINEERING"
        acct_env                            = "NON-PRODUCTION 1"
        agency                              = "MARYLAND TOTAL HUMAN-SERVICES INTEGRATED NETWORK"
        app                                 = "TERRAFORM ENTERPRISE"
        program                             = "MDTHINK SHARED PLATFORM"
        app_env                             = "NON PRODUCTION"
        domain                              = "ENGINEERING"
        pca                                 = "FE110"
        owner                               = "MDT DevOps"
    }
    s3                                      = {
        suffix                              = "TEST"
        purpose                             = "Mock Purpose"
        kms_key                             = {}
    }
}

run "validate_s3_bucket_name"{
    command = plan
    assert {
        condition = local.bucket_name == "s3-siege1-mdt-test"
        error_message = "Expected security group name did not generate from provided perameters. Expected: s3-siege1-mdt-test vs Actual: ${local.bucket_name}"
    }
}

run "validate_s3_tags" {
  command = plan
 
  assert {
    condition = alltrue([
        local.tags["Account"] == "IEG",
        local.tags["Agency"] == "MDT",
        local.tags["CreationDate"] != null, # Allows for wildcard matching
        local.tags["Environment"] == "DEV1",
        local.tags["Program"] == "MDT",
        local.tags["Region"] == "E1",
        local.tags["Purpose"] == "Mock Purpose"
    ])
    error_message = <<-EOT
      s3 tags do not match the expected values.
      Expected:
      - Account: IEG
      - Agency: MDT
      - CreationDate: *
      - Environment: DEV1
      - Program: MDT
      - Region: E1
      - Purpose: Mock Purpose
 
      Actual tags:
      ${jsonencode(local.tags)}
    EOT
  }
}
