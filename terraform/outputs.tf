output "custom_domain_name" {
  description = "This is the custom domain name of my API Gateway"
  value       =  aws_api_gateway_domain_name.example_domain_name.regional_domain_name
}

output "lambda_bucket_arn" {
  description = "Bucket arn where the lambda code is placed"
  value       = aws_s3_bucket.lambda_function_bucket.arn
}

output "other_bucket_arn" {
  description = "The other bucket where lambda created objects are placed"
  value       = aws_s3_bucket.other_bucket.arn
}