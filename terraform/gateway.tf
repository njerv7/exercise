resource "aws_api_gateway_rest_api" "my_lambda_gateway" {
  name        = "my_api_gateway"
  description = "API Gateway for Lambda function exercise"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "my_lambda_gateway" {
  parent_id   = aws_api_gateway_rest_api.my_lambda_gateway.root_resource_id
  path_part   = "exercise"
  rest_api_id = aws_api_gateway_rest_api.my_lambda_gateway.id
}

resource "aws_api_gateway_method" "my_lambda_gateway" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.my_lambda_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.my_lambda_gateway.id
}

resource "aws_api_gateway_integration" "my_lambda_gateway" {
  http_method             = aws_api_gateway_method.my_lambda_gateway.http_method
  resource_id             = aws_api_gateway_resource.my_lambda_gateway.id
  rest_api_id             = aws_api_gateway_rest_api.my_lambda_gateway.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.my_lambda_function.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.my_lambda_gateway.id
  resource_id = aws_api_gateway_resource.my_lambda_gateway.id
  http_method = aws_api_gateway_method.my_lambda_gateway.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "my_lambda_gateway" {
  rest_api_id = aws_api_gateway_rest_api.my_lambda_gateway.id
  resource_id = aws_api_gateway_resource.my_lambda_gateway.id
  http_method = aws_api_gateway_method.my_lambda_gateway.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_deployment" "my_lambda_gateway" {
  rest_api_id = aws_api_gateway_rest_api.my_lambda_gateway.id
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.my_lambda_gateway.id
  rest_api_id   = aws_api_gateway_rest_api.my_lambda_gateway.id
  stage_name    = "exercise"
}