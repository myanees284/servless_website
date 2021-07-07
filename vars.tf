variable "db_tables" {
  type    = list(string)
  default = ["courses", "authors"]
}
variable "region" { default = "us-west-2" }
variable "bucketname" { default = "superbucket" }
variable "iamRoleName" { default = "dynamodb_lambda" }
variable "event_source_arn" { default = "some event src urn" }
variable "rest_api_name" { default = "courses-api" }
variable "stage_name" { default = "dev_demo" }
variable "bucket" { default = "superbucket" }
variable "acl" { default = "public-read" }
variable "Environment" { default = "dev" }
variable "s3_origin_id" { default = "serverlessOrigin" }
