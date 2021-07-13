#provider tells terraform which cloud provider and region to use
provider "aws" {
  region = var.region
}

# IAM role creation
module "awsRole" {
  source               = "github.com/myanees284/terraform-aws-iamRole"
  policyFilePath       = "templates/dynamodb_policy.json"
  assumeRolePolicyName = "templates/assume_role_policy.json"
  iamRoleName          = var.iamRoleName
}

# lambda creation and attaching role
module "awsLambda" {
  for_each         = fileset("./python_files/", "*.py")
  source           = "github.com/myanees284/terraform-aws-lambda"
  iamRoleArn       = module.awsRole.iamRoleArn
  lambdaCodeFile   = "./python_files/${each.value}"
  event_source_arn = var.event_source_arn
}

# dynamo db table creation
resource "aws_dynamodb_table" "course-table" {
  count          = length(var.db_tables)
  name           = var.db_tables[count.index]
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
  provisioner "local-exec" {
    command = "aws dynamodb batch-write-item --request-items file://author-data.json --region ${var.region}"
  }
  tags = {
    Name = "${var.db_tables[count.index]}-table"
  }
}

#Creating API gateway with CORS resources enabled.
module "api_gw" {
  source        = "./modules/api_gw"
  rest_api_name = var.rest_api_name
  path_part     = var.db_tables
}

resource "aws_api_gateway_request_validator" "the" {
  name                        = "validate body"
  rest_api_id                 = module.api_gw.rest_api_id
  validate_request_body       = true
  validate_request_parameters = false
}


resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = module.api_gw.rest_api_id

  triggers = {
    redeployment = sha1(jsonencode([
      module.api_gw.resource_id[0],
      aws_api_gateway_method.courses_post.id,
      aws_api_gateway_integration.courses_post_lambda_integration.id,
      aws_api_gateway_method.courses_getAll.id,
      aws_api_gateway_integration.courses_getAll_lambda_integration.id,
      aws_api_gateway_method.course_child_method.id,
      aws_api_gateway_integration.course_child_integration.id,
      aws_api_gateway_method.PUT_method.id,
      aws_api_gateway_integration.PUT_method_integration.id,
      aws_api_gateway_method.GET_method.id,
      aws_api_gateway_integration.GET_method_integration.id,
      aws_api_gateway_method.DELETE_method.id,
      aws_api_gateway_integration.DELETE_method_integration.id,
      module.api_gw.resource_id[1],
      aws_api_gateway_method.authors_get.id,
      aws_api_gateway_integration.authors_get_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = module.api_gw.rest_api_id
  stage_name    = var.stage_name
}

resource "null_resource" "config_tasks" {
  provisioner "local-exec" {
    command = "bash config_tasks/run_config.sh ${aws_api_gateway_stage.stage.invoke_url}"
  }
  depends_on = [aws_api_gateway_deployment.deployment]
}