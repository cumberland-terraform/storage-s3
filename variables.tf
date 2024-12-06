variable "platform" {
  description                                   = "Platform metadata configuration object."
  type                                          = object({
    client                                      = string 
    environment                                 = string
  })
}

variable "kms" {
  description                   = "KMS Key configuration object. If not provided, a key will be provisioned. An AWS managed key can be used by specifying `aws_managed = true`."
  type                          = object({
    aws_managed                 = optional(bool, false)
    id                          = optional(string, null)
    arn                         = optional(string, null)
    alias_arn                   = optional(string, null)
  })
  default                       = null
}

variable "s3" {
    description                 = "S3 bucket configuration object. If no `kms_key` (either by specifying the id, arn and alias arn of a KMS key to use, or by specifying it should be AWS managed) is provided for the encryption of resources, one will be provisioned. If using a pre-existing key, the key output from the KMS module should be passed in under the `kms_key` object. For the resource policy passed in through `policy`, the value should be a JSON string. By default, a policy is generated that allows all users in the caller AWS account *read*/*write* access, with the exception of ACL operations, i.e. all ACL operations are explicitly denied. Any additional permissions passed in through the `policy` will be merged into the default policy through a `aws_iam_policy_document` data block. `replicas` represents the number of replicas to create. Each replica will have its index appended to the end of the original bucket name. If replication is enabled, the `replication_role` *must* be set, or else the module will fail. For a more detailed discussion of the module paramaters and module structure, refer to the module documentation"
    
    type                                        = object({
        purpose                                 = string
        suffix                                  = optional(string, "01")
        acl                                     = optional(string, "private")

        public_access_block                     = optional(bool, true)

        logging                                 = optional(bool, false)
        notification                            = optional(bool, false)
        notification_events                     = optional(list(string), [
                                                    "s3:ObjectCreated:*",
                                                    "s3:ObjectRemoved:*"
                                                ])

        policy                                  = optional(string, null)

        # if `replicas` is set to >0, then `replication_role` must be set.
        replicas                                = optional(number, 0)
        replication_role                        = optional(object({
            arn                                 = string
            id                                  = string
            name                                = string
        }), null)

        versioning                              = optional(bool, true)

        # <PROPERTY: `website_configuration`>
        website_configuration                   = optional(object({
            enabled                             = optional(bool, false)
            # <PROPERTY: `website_configuration.index_document`>
            index_document                      = optional(object({
                suffix                          = string
            }), {
                # <DEFAULT VALUES: `website_configuration.index_document`>
                suffix                          = "index.html"
                # </DEFAULT VALUES: `website_configuration.index_document`>
            })
            # </PROPERTY: `website_configuration.error_document`>
            error_document                      = optional(object({
                key                             = string
            }), {
                # <DEFAULT VALUES: `website_configuration.error_document`>
                key                             = "index.html"
                # </DEFAULT VALUES: `website_configuration.error_document`>
            })
            # </PROPERTY: `website_configuration.error_document`>
        }), {
            # <DEFAULT VALUES: `website_configuration`>
            enabled                             = false
            index_document                      = null
            error_document                      = null
            # </DEFAULT VALUES: `website_configuration`>
        })
        # </PROPERTY: `website_configuration`>

        tags                                        = optional(map(any), null)

        lifecycle_configuration                     = optional(object({
            rules                                   = optional(list(object({
                id                                  = optional(string, "expire-after-30-days")
                status                              = optional(string, "Enabled")
                expiration                          = optional(object({
                    days                            = optional(number, 30)
                    expired_object_delete_marker    = optional(bool, true)
                }), null)
            })), [])
        }), null)

        cors_configuration                          = optional(object({
            rules                                   = optional(list(object({
                allowed_headers                     = optional(list(string), null)
                allowed_methods                     = optional(list(string), null)
                allowed_origins                     = optional(list(string), null)
                expose_headers                      = optional(list(string), null)
                max_age_seconds                     = optional(number, null)
            })), [])
        }), null)
    })
}

