resource "aws_api_gateway_method" "child_HTTP_method" {
  authorization      = "NONE"
  request_parameters = {}

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = var.http_method
}

resource "aws_api_gateway_method_response" "child_HTTP_method_response" {
  response_models = {
    "application/json" = "Empty"
  }

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = var.http_method
  status_code = "200"
  depends_on  = [aws_api_gateway_method.child_HTTP_method]
}

resource "aws_api_gateway_integration" "child_HTTP_method_integration" {
  type                    = "AWS"
  rest_api_id             = var.rest_api_id
  resource_id             = var.rest_api_id
  http_method             = var.http_method
  integration_http_method = "POST"
  // uri                     = module.awsLambda["updateCourse.py"].lambda_invoke_urn
  uri                     = var.lambda_invoke_urn
  request_templates = {
    "application/json" = <<EOF
{
  "id": $input.params('id'),
  "title" : $input.json('$.title'),
  "authorId" : $input.json('$.authorId'),
  "length" : $input.json('$.length'),
  "category" : $input.json('$.category'),
  "watchHref" : $input.json('$.watchHref')
}
EOF
  }
  passthrough_behavior ="WHEN_NO_TEMPLATES"
  // depends_on = [aws_api_gateway_method.aws_api_gateway_method_response]
  depends_on = [aws_api_gateway_method_response.child_HTTP_method_response]
}

resource "aws_api_gateway_integration_response" "child_HTTP_method_integration_response" {
  response_templates = {}
  rest_api_id        = var.rest_api_id
  resource_id        = var.rest_api_id
  http_method        = "PUT"
  status_code        = "200"
  // depends_on         = [aws_api_gateway_method.child_HTTP_method]
  depends_on         = [aws_api_gateway_integration.child_HTTP_method_integration]
}

resource "aws_lambda_permission" "child_HTTP_method_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  // function_name = module.awsLambda["updateCourse.py"].function_name
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.source_arn}/*/*/*"
  depends_on    = [aws_api_gateway_method.child_HTTP_method]
}