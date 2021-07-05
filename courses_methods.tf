locals {
  course_child_resource_id = aws_api_gateway_resource.course_child_resource.id
}
resource "aws_api_gateway_model" "courses_post_model" {
  name         = "Model1"
  content_type = "application/json"
  schema       = file("schema/save_course.json")
  rest_api_id  = module.api_gw.rest_api_id
}
resource "aws_api_gateway_method" "courses_post" {
  authorization      = "NONE"
  request_parameters = {}

  rest_api_id          = module.api_gw.rest_api_id
  resource_id          = module.api_gw.resource_id[0]
  http_method          = "POST"
  request_validator_id = aws_api_gateway_request_validator.the.id
  request_models = {
    "application/json" = aws_api_gateway_model.courses_post_model.name
  }
}

resource "aws_api_gateway_method_response" "courses_post_response" {
  response_models = {
    "application/json" = "Empty"
  }

  rest_api_id = module.api_gw.rest_api_id
  resource_id = module.api_gw.resource_id[0]
  http_method = "POST"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "true"
  }
  depends_on = [aws_api_gateway_method.courses_post]
}

resource "aws_api_gateway_integration" "courses_post_lambda_integration" {
  type                    = "AWS"
  rest_api_id             = module.api_gw.rest_api_id
  resource_id             = module.api_gw.resource_id[0]
  http_method             = "POST"
  integration_http_method = "POST"
  uri                     = module.awsLambda["save_course.py"].lambda_invoke_urn
}

resource "aws_api_gateway_integration_response" "courses_post_lambda_integration_response" {
  rest_api_id = module.api_gw.rest_api_id
  resource_id = module.api_gw.resource_id[0]
  http_method = "POST"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.courses_post_lambda_integration]
}



resource "aws_lambda_permission" "courses_post_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.awsLambda["save_course.py"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gw.execution_arn}/*/*/*"
  depends_on    = [module.api_gw.options_method]
}


### GET ALL COURSES#####

resource "aws_api_gateway_method" "courses_getAll" {
  authorization      = "NONE"
  request_parameters = {}

  rest_api_id = module.api_gw.rest_api_id
  resource_id = module.api_gw.resource_id[0]
  http_method = "GET"
}

resource "aws_api_gateway_method_response" "courses_getAll_response" {
  response_models = {
    "application/json" = "Empty"
  }

  rest_api_id = module.api_gw.rest_api_id
  resource_id = module.api_gw.resource_id[0]
  http_method = "GET"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "true"
  }
  depends_on = [aws_api_gateway_method.courses_getAll]
}

resource "aws_api_gateway_integration" "courses_getAll_lambda_integration" {
  type                    = "AWS"
  rest_api_id             = module.api_gw.rest_api_id
  resource_id             = module.api_gw.resource_id[0]
  http_method             = "GET"
  integration_http_method = "POST"
  uri                     = module.awsLambda["getAllCourses.py"].lambda_invoke_urn
  depends_on              = [aws_api_gateway_method_response.courses_getAll_response]
}

resource "aws_api_gateway_integration_response" "courses_getAll_lambda_integration_response" {
  rest_api_id = module.api_gw.rest_api_id
  resource_id = module.api_gw.resource_id[0]
  http_method = "GET"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.courses_getAll_lambda_integration]
}

resource "aws_lambda_permission" "courses_getAll_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.awsLambda["getAllCourses.py"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gw.execution_arn}/*/*/*"
  depends_on    = [module.api_gw.options_method]
}


###### CHILD RESOURCE#########

#Creating child resource
resource "aws_api_gateway_resource" "course_child_resource" {
  rest_api_id = module.api_gw.rest_api_id
  parent_id   = module.api_gw.resource_id[0]
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "course_child_method" {
  authorization      = "NONE"
  request_parameters = {}
  rest_api_id        = module.api_gw.rest_api_id
  resource_id        = local.course_child_resource_id
  http_method        = "OPTIONS"
}

resource "aws_api_gateway_method_response" "course_child_method_reponse" {
  response_models = {
    "application/json" = "Empty"
  }

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "true",
    "method.response.header.Access-Control-Allow-Methods" = "true",
    "method.response.header.Access-Control-Allow-Origin"  = "true"
  }
  depends_on = [aws_api_gateway_method.course_child_method]
}

resource "aws_api_gateway_integration" "course_child_integration" {
  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "OPTIONS"
  depends_on  = [aws_api_gateway_method.course_child_method]
}

resource "aws_api_gateway_integration_response" "course_child_integration_response" {
  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.course_child_integration]
}


#Creating the HTTP methods PUT DELETE GET for Courses resource
// module "child_methods" {
//   count       = length(var.http_method)
//   source      = "./modules/child_methods"
//   rest_api_id = module.api_gw.rest_api_id
//   resource_id = local.course_child_resource_id
//   http_method = var.http_method[count.index]
//   source_arn  = module.api_gw.execution_arn
//   lambda_invoke_urn=module.awsLambda["${var.http_methods_lambda[var.http_method[count.index]]}"].lambda_invoke_urn
//   function_name=module.awsLambda["${var.http_methods_lambda[var.http_method[count.index]]}"].function_name
// }

######## CHILD -PUT###########
resource "aws_api_gateway_method" "PUT_method" {
  authorization      = "NONE"
  request_parameters = {}

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "PUT"
}

resource "aws_api_gateway_method_response" "PUT_method_response" {
  response_models = {
    "application/json" = "Empty"
  }

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "PUT"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "true"
  }

  depends_on = [aws_api_gateway_method.PUT_method]
}

resource "aws_api_gateway_integration" "PUT_method_integration" {
  type                    = "AWS"
  rest_api_id             = module.api_gw.rest_api_id
  resource_id             = local.course_child_resource_id
  http_method             = "PUT"
  integration_http_method = "POST"
  uri                     = module.awsLambda["updateCourse.py"].lambda_invoke_urn
  request_templates = {
    "application/json" = <<EOF
{
  "id": "$input.params('id')",
  "title" : $input.json('$.title'),
  "authorId" : $input.json('$.authorId'),
  "length" : $input.json('$.length'),
  "category" : $input.json('$.category'),
  "watchHref" : $input.json('$.watchHref')
}
EOF
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  depends_on           = [aws_api_gateway_method.PUT_method]
}

resource "aws_api_gateway_integration_response" "PUT_method_integration_response" {
  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "PUT"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.PUT_method_integration]
}

resource "aws_lambda_permission" "updateCourse_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.awsLambda["updateCourse.py"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gw.execution_arn}/*/*/*"
  depends_on    = [aws_api_gateway_method.PUT_method]
}

######## CHILD -GET###########
resource "aws_api_gateway_method" "GET_method" {
  authorization      = "NONE"
  request_parameters = {}

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "GET"
}

resource "aws_api_gateway_method_response" "GET_method_response" {
  response_models = {
    "application/json" = "Empty"
  }

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "GET"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "true"
  }
  depends_on = [aws_api_gateway_method.GET_method]
}

resource "aws_api_gateway_integration" "GET_method_integration" {
  type                    = "AWS"
  rest_api_id             = module.api_gw.rest_api_id
  resource_id             = local.course_child_resource_id
  http_method             = "GET"
  integration_http_method = "POST"
  uri                     = module.awsLambda["getCourse.py"].lambda_invoke_urn
  request_templates = {
    "application/json" = <<EOF
{
  "id": "$input.params('id')"
}
EOF
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  depends_on           = [aws_api_gateway_method_response.GET_method_response]

}

resource "aws_api_gateway_integration_response" "GET_method_integration_response" {

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "GET"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.GET_method_integration]
}

resource "aws_lambda_permission" "getCourse_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.awsLambda["getCourse.py"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gw.execution_arn}/*/*/*"
  depends_on    = [aws_api_gateway_method.GET_method]
}

######## CHILD -DELETE###########
resource "aws_api_gateway_method" "DELETE_method" {
  authorization      = "NONE"
  request_parameters = {}

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "DELETE"
}

resource "aws_api_gateway_method_response" "DELETE_method_response" {
  response_models = {
    "application/json" = "Empty"
  }

  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "DELETE"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "true"
  }
  depends_on = [aws_api_gateway_method.DELETE_method]
}

resource "aws_api_gateway_integration" "DELETE_method_integration" {
  type                    = "AWS"
  rest_api_id             = module.api_gw.rest_api_id
  resource_id             = local.course_child_resource_id
  http_method             = "DELETE"
  integration_http_method = "POST"
  uri                     = module.awsLambda["deleteCourse.py"].lambda_invoke_urn
  request_templates = {
    "application/json" = <<EOF
{
  "id": "$input.params('id')"
}
EOF
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  depends_on           = [aws_api_gateway_method_response.DELETE_method_response]

}

resource "aws_api_gateway_integration_response" "DELETE_method_integration_response" {
  rest_api_id = module.api_gw.rest_api_id
  resource_id = local.course_child_resource_id
  http_method = "DELETE"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.DELETE_method_integration]
}

resource "aws_lambda_permission" "deleteCourse_lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.awsLambda["deleteCourse.py"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gw.execution_arn}/*/*/*"
  depends_on    = [aws_api_gateway_method.DELETE_method]
}