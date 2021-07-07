resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket
  acl    = var.acl
  # to delete non empty bucket at terraform destroy
  force_destroy = true
  policy        = templatefile("templates/s3-policy.json", { bucket = "${var.bucketname}" })
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
  tags = {
    Name        = var.bucket
    Environment = var.Environment
  }
}
locals {
  s3_origin_id = var.s3_origin_id
}

resource "null_resource" "upload_build_to_s3" {
  provisioner "local-exec" {
    command = "bash config_tasks/upload.sh ${path.module}/react-app-frontend/build ${aws_s3_bucket.bucket.id} ${aws_s3_bucket.bucket.website_endpoint}"
  }
  depends_on = [null_resource.config_tasks]
}
