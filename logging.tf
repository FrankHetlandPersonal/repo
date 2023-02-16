# Create a CloudWatch log group for the lambda function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.security_group_handler.function_name}"
}


# Add permission to the lambda function for it to be able to write to the log group
resource "aws_lambda_permission" "cloudwatch_logs" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.security_group_handler.function_name
  principal     = "logs.amazonaws.com"

  # Specify the ARN of the log group to associate with the lambda function
  source_arn = aws_cloudwatch_log_group.lambda_log_group.arn
}


# Create a CloudWatch log stream for the lambda function
resource "aws_cloudwatch_log_stream" "lambda_log_stream" {
  name = "lambda_log_stream"

  # Associate the log stream with the log group created above
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
}