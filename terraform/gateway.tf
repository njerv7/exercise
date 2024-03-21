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

resource "aws_route53_zone" "domain_r53_zone" {
  name = "example.com"
  private_zone = false
}

resource "aws_route53_record" "domain_r53_rec" {
  zone_id = aws_route53_zone.domain_r53_zone.zone_id
  name    = "custom"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_api_gateway_rest_api.my_lambda_gateway.id}.execute-api.eu-west-1.amazonaws.com"]
}

resource "aws_acm_certificate" "domain_cert" {
  domain_name       = "example.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "domain_cert_validation" {
  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_r53_rec : record.fqdn]
}

resource "aws_api_gateway_domain_name" "example_domain_name" {
  domain_name              = "api.example.com"
  regional_certificate_arn = aws_acm_certificate_validation.domain_cert_validation.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}