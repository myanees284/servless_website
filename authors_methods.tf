resource "aws_api_gateway_method" "authors_get" {
  authorization      = "NONE"
  request_parameters = {}

  rest_api_id = module.api_gw.rest_api_id
  resource_id = module.api_gw.resource_id[1]
  http_method = "GET"
}

resource "aws_api_gateway_method_response" "authors_get_response" {
  response_models = {
    "application/json" = "Empty"
  }

  rest_api_id = module.api_gw.rest_api_id
  resource_id = module.api_gw.resource_id[1]
  http_method = "GET"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "true"
  }
  depends_on = [aws_api_gateway_method.authors_get]
}

resource "aws_api_gateway_integration" "authors_get_lambda_integration" {
  type                    = "AWS"
  rest_api_id             = module.api_gw.rest_api_id
  resource_id             = module.api_gw.resource_id[1]
  http_method             = "GET"
  integration_http_method = "POST"
  uri                     = module.awsLambda["getAllAuthors.py"].lambda_invoke_urn
  depends_on              = [aws_api_gateway_method_response.authors_get_response]
}

resource "aws_api_gateway_integration_response" "authors_get_lambda_integration_response" {
  rest_api_id = module.api_gw.rest_api_id
  resource_id = module.api_gw.resource_id[1]
  http_method = "GET"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.authors_get_lambda_integration]
}

resource "aws_lambda_permission" "getAllAuthors_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.awsLambda["getAllAuthors.py"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gw.execution_arn}/*/*/*"
  depends_on    = [aws_api_gateway_method.authors_get]
}