resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "IN", "GB", "AE"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  default_root_object = "index.html"
  enabled             = true
  retain_on_delete    = true
  depends_on          = [null_resource.upload_build_to_s3]
}

resource "null_resource" "cloudfronturl" {
  provisioner "local-exec" {
    command = "bash config_tasks/cloudfront-url.sh ${aws_cloudfront_distribution.s3_distribution.domain_name}"
  }
  depends_on = [aws_cloudfront_distribution.s3_distribution]
}
