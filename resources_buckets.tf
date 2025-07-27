# NOTE: first bucket is treated as the source bucket, all other buckets are treated as replicas
resource "aws_s3_bucket" "this" {
    count                       = local.total_buckets

    bucket                      = count.index == 0 ? (
                                    local.bucket_name
                                ) : "${local.bucket_name}-repl-0${count.index}"
    tags                        = local.tags

    lifecycle {
       ignore_changes          = [ tags ]
    }
}

resource "aws_s3_bucket_policy" "this" {
    lifecycle {
        # Ignore changes made in console
        # TODO: need to upate AWS conditions in bucket policy for email bucket
        ignore_changes          = [ policy ]
    }

    count                       = local.conditions.attach_policy ? local.total_buckets : 0

    bucket                      = aws_s3_bucket.this[count.index].id
    policy                      = data.aws_iam_policy_document.policy[count.index].json
}

resource "aws_s3_bucket_public_access_block" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id
    block_public_acls           = local.public_access_block.block_public_acls
    block_public_policy         = local.public_access_block.block_public_policy
    ignore_public_acls          = local.public_access_block.ignore_public_acls
    restrict_public_buckets     = local.public_access_block.restrict_public_buckets
}

resource "aws_s3_bucket_ownership_controls" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id

    rule {
        object_ownership        = local.platform_defaults.ownership_controls.object_ownership
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
    count                       = local.total_buckets

    bucket                      = aws_s3_bucket.this[count.index].id
    expected_bucket_owner       = module.platform.aws.account_id

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id   = local.kms_key_arn
            sse_algorithm       = local.sse_algorithm
        }
        bucket_key_enabled      = true
    }
}

resource "aws_s3_bucket_versioning" "this" {
    count                       = var.s3.versioning ? local.total_buckets : 0

    bucket                      = aws_s3_bucket.this[count.index].id

    versioning_configuration {
        status                  = local.platform_defaults.versioning.status
    }
}