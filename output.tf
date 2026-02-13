output "fun_uri" {
  value = aws_lambda_function_url.dynamic_string.function_url
  description = "The URL of the Lambda function, which can be used to invoke it directly."
}