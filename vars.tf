variable "db_tables" {
  type    = list(string)
  default = ["courses", "authors"]
}
variable "locations" {
  type    = list(string)
  default = ["US", "IN", "GB", "AE"]
}
variable "region" { default = "ap-south-1" }
variable "bucketname" { default = "superbucket" }
variable "iamRoleName" { default = "dynamodb_lambda" }
variable "event_source_arn" { default = "some event src urn" }
variable "rest_api_name" { default = "courses-api" }
variable "stage_name" { default = "dev_demo" }
variable "acl" { default = "public-read" }
variable "Environment" { default = "dev" }
variable "s3_origin_id" { default = "serverlessOrigin" }
variable "restriction_type" { default = "whitelist" }
variable "default_root_object" { default = "index.html" }
variable "domain" { default = "jewishgan.ga" }
