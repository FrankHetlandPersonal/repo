# This resource creates a CloudWatch event rule that listens for security group changes in EC2, 
# and triggers the lambda function when a security group changes.
resource "aws_cloudwatch_event_rule" "security_group_changes" {
  name        = "security_group_changes"
  description = "Trigger lambda on security group changes"

  # The event pattern specifies the event to listen for
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail_type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["ec2.amazonaws.com"]
      eventName   = ["AuthorizeSecurityGroupIngress", "AuthorizeSecurityGroupEgress", "RevokeSecurityGroupIngress", "RevokeSecurityGroupEgress"]
    }
  })
}

# This resource creates an event target that directs the events to the lambda function.
resource "aws_cloudwatch_event_target" "target" {
  rule = aws_cloudwatch_event_rule.security_group_changes.name

  # The Amazon Resource Name (ARN) of the Lambda function to invoke
  arn = aws_lambda_function.security_group_handler.arn
}