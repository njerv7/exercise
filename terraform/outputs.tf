output "custom_domain_name" {
    description = "This is the custom domain name of my API Gateway"
    value       =  aws_api_gateway_domain_name.example_domain_name.regional_domain_name
}