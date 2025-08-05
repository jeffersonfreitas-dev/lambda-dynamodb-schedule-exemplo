output "lambda_name" {
  value = aws_lambda_function.generate_token.function_name
}

output "dynamodb_table" {
  value = aws_dynamodb_table.cache-token_table.name
}

output "eventbridge_rule" {
  value = aws_cloudwatch_event_rule.lambda_schedule.name
}