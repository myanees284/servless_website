resource "aws_api_gateway_rest_api" "rest_api" {
  name = "${var.rest_api_name}"
}

resource "aws_api_gateway_resource" "api_resource" {
count=length(var.path_part)
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  rest_api_id = local.api_parent_id
  path_part   = var.path_part[count.index]
}

resource "aws_api_gateway_method" "options_method" {
count=length(aws_api_gateway_resource.api_resource)
  rest_api_id   = local.api_parent_id
  resource_id   = local.api_resource_ids[count.index]
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
count=length(aws_api_gateway_resource.api_resource)
  rest_api_id = local.api_parent_id
  resource_id = local.api_resource_ids[count.index]
#   http_method = aws_api_gateway_method.options_method.http_method
 http_method = "OPTIONS"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
   response_parameters ={
        "method.response.header.Access-Control-Allow-Headers" = "true",
        "method.response.header.Access-Control-Allow-Methods" = "true",
        "method.response.header.Access-Control-Allow-Origin" = "true"
    }
  depends_on = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration" "apigateway4f87658" {
count=length(aws_api_gateway_resource.api_resource)
  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
  rest_api_id = local.api_parent_id
  resource_id = local.api_resource_ids[count.index]
  http_method = "OPTIONS"
   depends_on  = [aws_api_gateway_method.options_method]
}

resource "aws_api_gateway_integration_response" "apigateway33ebd5b" {
count=length(aws_api_gateway_resource.api_resource)
  rest_api_id = local.api_parent_id
  resource_id = local.api_resource_ids[count.index]
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
  response_templates = {
     "application/json" = ""
  }

  depends_on  = [aws_api_gateway_integration.apigateway4f87658]
}