output "bucket" {
    description                             = "Map containing metadata for the source S3 bucket and its replicas. The smallest index/key of the map will always be the source bucket, the next largest will be the logging bucket and the rest will be replicas of the source bucket."
    value                                   = {
        for bucket_key, bucket in aws_s3_bucket.this:
            bucket_key                      => {
                arn                         = bucket.arn
                id                          = bucket.id
                bucket_regional_domain_name = bucket.bucket_regional_domain_name
            } 
    }
}

output "website_configuration" {
    description                             = "Optional output if static web service is configured"
    value                                   = local.conditions.is_website ? (
                                                aws_s3_bucket_website_configuration.this[0]
                                            ): null
}