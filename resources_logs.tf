resource "aws_s3_bucket" "logs" {
    count                       = var.s3.logging ? 1 : 0

    bucket                      = "${local.bucket_name}-logs"
    
    lifecycle {
        # prevent_destroy         = true
    }

}

resource "aws_s3_bucket_logging" "this" {
    count                       = var.s3.logging ? (
                                    local.total_buckets
                                ) : 0

    bucket                      = aws_s3_bucket.this[count.index].id
    target_bucket               = aws_s3_bucket.logs[count.index].id
    target_prefix               = "log/${count.index == 0 ? "source" : "replica-0${count.index}"}"
}


resource "aws_s3_bucket_public_access_block" "logs" {
    count                       = var.s3.logging ? 1 : 0

    bucket                      = aws_s3_bucket.logs[count.index].id
    block_public_acls           = true
    block_public_policy         = true
    ignore_public_acls          = true
    restrict_public_buckets     = true
}

resource "aws_s3_bucket_acl" "logs" {
    count                       = var.s3.logging ? 1 : 0
    depends_on                  = [ aws_s3_bucket_ownership_controls.logs ]

    bucket                      = aws_s3_bucket.logs[count.index].id
    acl                         = "log-delivery-write"
    expected_bucket_owner       = module.platform.aws.account_id
}

resource "aws_s3_bucket_ownership_controls" "logs" {
    count                       = var.s3.logging ? 1 : 0

    bucket                      = aws_s3_bucket.logs[count.index].id

    rule {
        object_ownership        = local.platform_defaults.ownership_controls.object_ownership
    }
}


resource "aws_s3_bucket_versioning" "logs" {
    count                       = var.s3.logging ? 1 : 0

    bucket                      = aws_s3_bucket.logs[count.index].id

    versioning_configuration {
        status                  = local.platform_defaults.versioning.status
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
    count                       = var.s3.logging ? 1 : 0

    bucket                      = aws_s3_bucket.logs[count.index].id
    expected_bucket_owner       = module.platform.aws.account_id

    rule {
        apply_server_side_encryption_by_default {
            kms_master_key_id   = local.kms_key_arn
            sse_algorithm       = local.sse_algorithm
        }
    }
}
