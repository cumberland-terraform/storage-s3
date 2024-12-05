locals {    
    ## PLATFORM DEFAULTS
    #   These are platform specific configuration options. They should only need
    #       updated if the platform itself changes.    
    platform_defaults               = {
        ownership_controls          = {
            object_ownership        = "BucketOwnerEnforced"
        }
        versioning                  = {
            status                  = "Enabled"
        }
        replication                 = {
            status                  = "Enabled"
            storage_class           = "STANDARD"
        }
        public_access_block         = {
            block_public_acls       = true
            block_public_policy     = true
            ignore_public_acls      = true
            restrict_public_buckets = true
        }
    }
    
    ## CONDITIONS
    #   Configuration object containing boolean calculations that correspond
    #       to different deployment configurations.
    conditions                      = {
        attach_policy               = var.s3.policy != null
        provision_key               = var.s3.kms_key == null
        replicate                   = var.s3.replicas > 0
        notify                      = var.s3.notification
        is_website                  = var.s3.website_configuration.enabled
        has_lifecycle               = var.s3.lifecycle_configuration != null
        has_cors                    = var.s3.cors_configuration != null
    }

    ## CALCULATED PROPERTIES
    #   Variables that change based on deployment configuration. 
    tags                            = merge({
        Purpose                     = var.s3.purpose
    }, var.s3.tags, module.platform.tags)

    bucket_name                     = lower(join("-", [
                                        "S3",
                                        module.platform.prefix,
                                        var.s3.suffix
                                    ]))
    # KMS Key outcomes:
    #   1. Module provisions its own KMS key.
    #   2. Module uses KMS key that was passed in.
    #   3. Module sets KMS key to null and allows AWS to manage it.
    managed_kms_key_alias_arn       = join("/", [
                                        module.platform.aws.arn.kms.alias,
                                        "aws",
                                        "s3"
                                    ])

    kms_key_arn                     = local.conditions.provision_key ? (
                                        module.kms[0].key.arn
                                    ) : !var.s3.kms_key.aws_managed ? ( 
                                        var.s3.kms_key.arn
                                    ): null
                                    
    kms_key_alias_arn               = local.conditions.provision_key ? (
                                        module.kms[0].key.alias_arn
                                    ) : var.s3.kms_key.aws_managed ? (
                                        local.managed_kms_key_alias_arn
                                    ): var.s3.kms_key.alias_arn

    sse_algorithm                   = local.conditions.provision_key || !var.s3.kms_key.aws_managed ? (
                                        "aws:kms" ) : ( "AES256" )

    # Replication Configuration
    total_buckets                   = var.s3.replicas + 1

    source_bucket_arns              = [
                                        "arn:aws:s3:::${local.bucket_name}",
                                        "arn:aws:s3:::${local.bucket_name}/*"
                                    ]

    destination_bucket_arns         = [ for i in range(1, local.total_buckets): 
                                        "arn:aws:s3:::${local.bucket_name}-replica-0${i}" 
                                    ]

    destination_bucket_path_arns    = [ for i in range(1, local.total_buckets): 
                                        "arn:aws:s3:::${local.bucket_name}-replica-0${i}/*"
                                    ]
    # Event Configuration
    event_notification_id           = "${local.bucket_name}-notifications"
    
    event_notification_arn          = "arn:aws:sns:*:*:${local.event_notification_id}"
}