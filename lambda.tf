# Define an AWS Lambda function resource for the security group handler
resource "aws_lambda_function" "security_group_handler" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_execution.arn
  handler       = "${var.function_name}.${var.handler_name}"
  runtime       = "python3.9"
  filename      = "${var.code_path_python}/${var.function_name}.zip"

  # Use the base64-encoded SHA256 hash of the ZIP file as the source code hash
  source_code_hash = filebase64sha256("${var.code_path_python}/${var.function_name}.zip")

  # Adding SNS topic to the function environment variables
  environment {
    variables = {
      SNS_TOPIC_ARN = "sns_topic_arn"
    }
  }

  # Add a Lambda layer to the function, if needed
  # layers = [aws_lambda_layer_version.layer.arn]
}
