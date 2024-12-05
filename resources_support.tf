resource "aws_iam_policy" "this" {
    count                               = local.conditions.replicate ? 1 : 0

    name                                = "${local.bucket_name}-S3-REPL"
    policy                              = data.aws_iam_policy_document.replication[count.index].json
}

resource "aws_iam_role_policy_attachment" "this" {
  count                                 = local.conditions.replicate ? 1 : 0

  role                                  = var.s3.replication_role.name
  policy_arn                            = aws_iam_policy.this[count.index].arn
}

resource "aws_sns_topic" "this" {
  count                                 = local.conditions.notify ? 1 : 0

  kms_master_key_id                     = local.kms_key_alias_arn
  name                                  = local.event_notification_id
  policy                                = data.aws_iam_policy_document.notification[count.index].json
}

resource "aws_s3_bucket_notification" "this" {
    count                               = var.s3.notification ? 1 : 0
    bucket                              = aws_s3_bucket.this[0].id

    topic {
        topic_arn                       = aws_sns_topic.this[count.index].arn
        events                          = var.s3.notification_events
    }
}

resource "aws_s3_bucket_replication_configuration" "this" {
  count                                 = local.conditions.replicate ? 1 : 0
  
  role                                  = var.s3.replication_role.arn
  bucket                                = aws_s3_bucket.this[count.index].id

  rule {
      status                            = local.platform_defaults.replication.status

      dynamic "destination" {
          for_each                      = { 
              for k,v in aws_s3_bucket.this:
                  k                     => v if k > 0 
          }
          
          content {
              bucket                    = destination.value["arn"]
              storage_class             = local.platform_defaults.replication.storage_class
          }
      }
  }
}

resource "aws_s3_bucket_website_configuration" "this" {
  count                                 = local.conditions.is_website ? 1 : 0

  bucket                                = aws_s3_bucket.this[count.index].id

  index_document {
    suffix                              = var.s3.website_configuration.index_document.suffix
  }

  error_document {
    key                                 = var.s3.website_configuration.error_document.key
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count                                 = local.conditions.has_lifecycle ? 1 : 0  

  bucket                                = aws_s3_bucket.this[count.index].id
  expected_bucket_owner                 = module.platform.aws.account_id

  dynamic "rule" {
    for_each                            = { for index, rule in var.s3.lifecycle_configuration.rules: 
                                            index => rule }  
    
    content {
      id                                = rule.value.id
      status                            = rule.value.status

      dynamic "expiration" {
        for_each                        = try(rule.value.expiration, null) == null ? (
                                          toset([]) 
                                        ) : toset([1])

        content {
          date                          = try(expiration.value.date, null)
          expired_object_delete_marker  = try(expiration.value.expired_object_delete_marker, null)
        }
      }
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  count                                 = local.conditions.has_cors ? 1 : 0
  bucket                                = aws_s3_bucket.this[count.index].id

  dynamic "cors_rule" {
    for_each                            = { for index, rule in var.s3.cors_configuration.rules:
                                            index => rule }

    content {
      allowed_headers                   = cors_rule.value.allowed_headers
      allowed_origins                   = cors_rule.value.allowed_origins
      allowed_methods                   = cors_rule.value.allowed_methods
      expose_headers                    = cors_rule.value.expose_headers
      max_age_seconds                   = cors_rule.value.max_age_seconds
    }
  }
}