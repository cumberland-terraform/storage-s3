data "aws_iam_policy_document" "policy" {
    count                   = local.conditions.attach_policy ? local.total_buckets : 0
                              

    source_policy_documents = concat(
                              var.s3.policy != null ? [ 
                                var.s3.policy 
                              ] : [], 
                              local.conditions.is_website ? [
                                data.aws_iam_policy_document.web_policy.json
                              ] : []
                            )
}

data "aws_iam_policy_document" "web_policy" {
  
  statement {
    effect                  = "Allow"
    actions                 = [ "s3:GetObject"]
    resources               = [ 
                              aws_s3_bucket.this[0].arn,
                              "${aws_s3_bucket.this[0].arn}/*"
                            ] 

    principals {
      type                  = "*"
      identifiers           = [ "*" ]
    }

    # condition {
    #   test                  = "Bool"
    #   variable              = "aws:SecureTransport"
    #   values                = [ true ]
    # }
  }
}

data "aws_iam_policy_document" "replication" {
  count                       = local.conditions.replicate ? 1 : 0

  statement {
    effect                  = "Allow"
    actions                 = [
                              "s3:GetReplicationConfiguration",
                              "s3:ListBucket"
                            ]
    resources               = local.source_bucket_arns

    condition {
      test                  = "StringEquals"
      variable              = "aws:SourceAccount"
      values                = [ module.platform.aws.account_id ]
    }
  }

  statement {
    effect                  = "Allow"
    actions                 = [
                              "s3:GetObjectVersionForReplication",
                              "s3:GetObjectVersionAcl",
                              "s3:GetObjectVersionTagging"
                            ]
    resources               = local.source_bucket_arns

    condition {
      test                  = "StringEquals"
      variable              = "aws:SourceAccount"
      values                = [ module.platform.aws.account_id ]
    }
  }

  statement {
    effect                  = "Allow"
    actions                 = [
                              "s3:ReplicateObject",
                              "s3:ReplicateDelete",
                              "s3:ReplicateTags"
                            ]
    resources               = local.destination_bucket_arns
    
    condition {
      test                  = "StringEquals"
      variable              = "aws:SourceAccount"
      values                = [ module.platform.aws.account_id ]
    }
  }
}

data "aws_iam_policy_document" "notification" {
  count                     = var.s3.notification ? 1 : 0
  
  statement {
    effect                  = "Allow"
    actions                 = [ "sns:Publish"]
    resources               = [ local.event_notification_arn ]

    condition {
      test                  = "ArnLike"
      variable              = "aws:SourceArn"
      values                = [ aws_s3_bucket.this[0].arn ] 
    }

    principals {
      type                  = "*"
      identifiers           = [ "*" ]
    }
  }

  statement {
    effect                  = "Allow"
    actions                 = [ "s3:PutObject"]

    condition {
      test                  = "StringEquals"
      variable              = "aws:Referrer"
      values                = [ module.platform.aws.account_id ]
    }
    principals {
      type                  = "Service"
      identifiers           = [ "ses.amazonaws.com" ]
    }

  }
}