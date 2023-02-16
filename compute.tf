# Create a zip archive of the python code for the lambda function
data "archive_file" "security_group_handler" {
  type        = "zip"
  source_file = "${var.code_path_python}/${var.function_name}.py"
  output_path = "${var.code_path_python}/${var.function_name}.zip"
}


# For debugging purposes
# data "aws_cloudwatch_log_group" "lambda_log_group" {
#   name = "/aws/lambda/${aws_lambda_function.security_group_handler.function_name}"
# }

# data "aws_cloudwatch_log_stream" "lambda_log_stream" {
#   name            = "lambda_log_stream"
#   log_group_name  = data.aws_cloudwatch_log_group.lambda_log_group.name
#   most_recent     = true
#   order_by        = "LastEventTime"
#   descending      = true
#   include_pattern = "ERROR"
# }

# output "lambda_logs" {
#   value = data.aws_cloudwatch_log_stream.lambda_log_stream.events
# }
