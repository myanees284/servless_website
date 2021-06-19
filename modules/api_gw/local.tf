#repeated lengthy expressions used in the code are stored in locals. And accessed as local.<variable name>
locals {
api_parent_id=aws_api_gateway_rest_api.rest_api.id
api_resource_ids=aws_api_gateway_resource.api_resource.*.id
execution_arn=aws_api_gateway_rest_api.rest_api.execution_arn
}